#!/usr/bin/env python3
"""
Organize Apple Music folder structure by consolidating split albums.

This script identifies albums that have been split across multiple artist folders
(e.g., "Tweaker" vs "Tweaker & David Sylvian") and consolidates them under the
main artist folder. For compilation albums appearing under multiple unrelated
artists, it creates a "Various Artists" folder.

Usage:
    python3 organize-music.py [--dry-run] [--music-dir PATH]
"""

import json
import os
import re
import shutil
import sys
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional


def extract_track_number(filename: str) -> Optional[int]:
    """Extract track number from filename (e.g., '01 Track.flac' -> 1)."""
    match = re.match(r'^(\d+)', filename)
    if match:
        return int(match.group(1))
    return None


def get_artists_and_albums(music_dir: Path) -> Dict[str, Dict[str, List[str]]]:
    """
    Scan music directory and return structure: {artist: {album: [tracks]}}

    Returns:
        Dictionary mapping artist names to their albums and tracks
    """
    structure = defaultdict(lambda: defaultdict(list))

    for artist_dir in music_dir.iterdir():
        if not artist_dir.is_dir() or artist_dir.name.startswith('.'):
            continue

        artist_name = artist_dir.name

        for album_dir in artist_dir.iterdir():
            if not album_dir.is_dir():
                continue

            album_name = album_dir.name

            # Get all audio files
            tracks = []
            for track_file in album_dir.iterdir():
                if track_file.is_file() and track_file.suffix.lower() in ['.flac', '.mp3', '.m4a', '.aac', '.wav']:
                    tracks.append(track_file.name)

            if tracks:
                structure[artist_name][album_name] = sorted(tracks)

    return dict(structure)


def is_main_artist(main_artist: str, multi_artist: str) -> bool:
    """
    Check if main_artist is the primary artist in multi_artist.

    Example:
        is_main_artist("Tweaker", "Tweaker & David Sylvian") -> True
        is_main_artist("David Sylvian", "Tweaker & David Sylvian") -> False
    """
    # Multi-artist format: "Artist1 & Artist2" or "Artist1, Artist2 & Artist3"
    parts = [p.strip() for p in re.split(r'[,&]', multi_artist)]
    return main_artist in parts and parts[0] == main_artist


def find_main_artist(multi_artist: str, all_artists: Set[str]) -> Optional[str]:
    """
    Find the main artist folder for a multi-artist folder.

    Returns the single-artist folder name if it exists, None otherwise.
    """
    parts = [p.strip() for p in re.split(r'[,&]', multi_artist)]

    # Check if first part exists as a standalone artist
    if parts[0] in all_artists:
        return parts[0]

    return None


def get_track_numbers(tracks: List[str]) -> Set[int]:
    """Extract all track numbers from a list of track filenames."""
    track_nums = set()
    for track in tracks:
        num = extract_track_number(track)
        if num is not None:
            track_nums.add(num)
    return track_nums


def analyze_album_completeness(tracks: List[str]) -> Tuple[bool, Set[int], List[int]]:
    """
    Analyze if an album appears complete based on track numbering.

    Returns:
        (is_complete, track_numbers_set, missing_tracks_list)
    """
    track_nums = get_track_numbers(tracks)

    if not track_nums:
        # No numbered tracks - assume complete
        return True, track_nums, []

    min_track = min(track_nums)
    max_track = max(track_nums)

    # Check for gaps
    expected = set(range(min_track, max_track + 1))
    missing = sorted(expected - track_nums)

    # Consider complete if no gaps or only small gaps (might be intentional)
    is_complete = len(missing) == 0

    return is_complete, track_nums, missing


def find_duplicate_albums(structure: Dict[str, Dict[str, List[str]]]) -> Dict[str, List[Tuple[str, str]]]:
    """
    Find albums that appear under multiple artists.

    Returns:
        {album_name: [(artist1, album_path), (artist2, album_path), ...]}
    """
    album_locations = defaultdict(list)

    for artist, albums in structure.items():
        for album_name in albums.keys():
            album_locations[album_name].append((artist, album_name))

    # Filter to only albums appearing under multiple artists
    duplicates = {album: locations for album, locations in album_locations.items()
                  if len(locations) > 1}

    return duplicates


def plan_consolidations(music_dir: Path, structure: Dict[str, Dict[str, List[str]]]) -> List[Dict]:
    """
    Plan what consolidations need to happen.

    Returns list of operations to perform:
    [
        {
            'type': 'merge_to_main' | 'merge_to_various',
            'source_artist': 'Tweaker & David Sylvian',
            'source_album': '2 AM Wakeup Call',
            'target_artist': 'Tweaker',
            'target_album': '2 AM Wakeup Call',
            'tracks_to_move': ['06 Pure Genius.flac'],
            'source_tracks': [...],
            'target_tracks': [...],
            'will_be_complete': True/False
        },
        ...
    ]
    """
    operations = []
    all_artists = set(structure.keys())

    # Find all multi-artist folders
    multi_artist_folders = [a for a in all_artists if '&' in a or ',' in a]

    # Case 1: Multi-artist folders that have a main artist
    for multi_artist in multi_artist_folders:
        main_artist = find_main_artist(multi_artist, all_artists)

        if not main_artist:
            continue

        # Check for overlapping albums
        multi_albums = set(structure[multi_artist].keys())
        main_albums = set(structure[main_artist].keys())
        overlapping = multi_albums & main_albums

        for album_name in overlapping:
            multi_tracks = structure[multi_artist][album_name]
            main_tracks = structure[main_artist][album_name]

            # Get track numbers
            multi_nums = get_track_numbers(multi_tracks)
            main_nums = get_track_numbers(main_tracks)

            # Find tracks in multi-artist that aren't in main
            tracks_to_move = []
            for track in multi_tracks:
                track_num = extract_track_number(track)
                if track_num and track_num not in main_nums:
                    tracks_to_move.append(track)
                elif not track_num:
                    # Unnumbered track - check if filename exists
                    if track not in main_tracks:
                        tracks_to_move.append(track)

            if tracks_to_move:
                # Check if result will be complete
                combined_tracks = sorted(set(main_tracks + tracks_to_move))
                will_be_complete, track_nums, missing_tracks = analyze_album_completeness(combined_tracks)

                operations.append({
                    'type': 'merge_to_main',
                    'source_artist': multi_artist,
                    'source_album': album_name,
                    'target_artist': main_artist,
                    'target_album': album_name,
                    'tracks_to_move': tracks_to_move,
                    'source_tracks': multi_tracks,
                    'target_tracks': main_tracks,
                    'combined_tracks': combined_tracks,
                    'will_be_complete': will_be_complete,
                    'track_numbers': track_nums,
                    'missing_tracks': missing_tracks
                })

    # Case 2: Compilation albums (same album under multiple unrelated artists)
    duplicate_albums = find_duplicate_albums(structure)

    for album_name, locations in duplicate_albums.items():
        # Skip if we already handled this in Case 1
        artists_involved = {loc[0] for loc in locations}
        if any('&' in a or ',' in a for a in artists_involved):
            # Check if this was handled by Case 1
            handled = False
            for op in operations:
                if op['source_album'] == album_name or op['target_album'] == album_name:
                    handled = True
                    break
            if handled:
                continue

        # This is a compilation - consolidate to Various Artists
        # Find the artist with the most tracks (likely the "main" one)
        artist_track_counts = [(loc[0], len(structure[loc[0]][album_name]))
                              for loc in locations]
        artist_track_counts.sort(key=lambda x: x[1], reverse=True)

        target_artist = 'Various Artists'
        source_locations = [(loc[0], album_name) for loc in locations]

        # Collect all tracks from all locations
        all_tracks = []
        for artist, album in source_locations:
            all_tracks.extend(structure[artist][album])

        unique_tracks = sorted(set(all_tracks))
        will_be_complete, track_nums, missing_tracks = analyze_album_completeness(unique_tracks)

        operations.append({
            'type': 'merge_to_various',
            'source_locations': source_locations,
            'target_artist': target_artist,
            'target_album': album_name,
            'all_tracks': unique_tracks,
            'will_be_complete': will_be_complete,
            'track_numbers': track_nums,
            'missing_tracks': missing_tracks
        })

    return operations


def print_operation_summary(operations: List[Dict], dry_run: bool = True):
    """Print a concise summary with resulting file structure and missing tracks."""
    if not operations:
        print("✅ No consolidations needed - music library is already organized!")
        return

    print(f"\n{'DRY RUN - ' if dry_run else ''}Consolidation Plan ({len(operations)} operation(s)):\n")

    merge_to_main = [op for op in operations if op['type'] == 'merge_to_main']
    merge_to_various = [op for op in operations if op['type'] == 'merge_to_various']

    # Group merge_to_main by target album
    albums_by_target = defaultdict(list)
    for op in merge_to_main:
        key = (op['target_artist'], op['target_album'])
        albums_by_target[key].append(op)

    # Print main artist consolidations
    if merge_to_main:
        for (target_artist, target_album), ops in albums_by_target.items():
            # Collect all tracks that will be in final album
            all_final_tracks = set()
            sources = []
            for op in ops:
                all_final_tracks.update(op['target_tracks'])
                all_final_tracks.update(op['tracks_to_move'])
                sources.append(f"{op['source_artist']} ({len(op['tracks_to_move'])} track(s))")

            # Recalculate completeness for the combined final album
            final_tracks = sorted(all_final_tracks)
            will_be_complete, _, missing_tracks = analyze_album_completeness(final_tracks)

            print(f"{target_artist}/{target_album}")
            print(f"  Sources: {', '.join(sources)}")
            print(f"  Result: {len(final_tracks)} track(s)")

            if missing_tracks:
                print(f"  ⚠️  Missing tracks: {', '.join(f'{n:02d}' for n in missing_tracks)}")
            elif will_be_complete:
                print(f"  ✅ Complete")
            print()

    # Print compilation consolidations
    if merge_to_various:
        for op in merge_to_various:
            source_artists = [loc[0] for loc in op['source_locations']]
            print(f"{op['target_artist']}/{op['target_album']}")
            print(f"  Sources: {len(source_artists)} artist(s) ({', '.join(source_artists[:3])}{'...' if len(source_artists) > 3 else ''})")
            print(f"  Result: {len(op['all_tracks'])} track(s)")

            if op['missing_tracks']:
                print(f"  ⚠️  Missing tracks: {', '.join(f'{n:02d}' for n in op['missing_tracks'])}")
            elif op['will_be_complete']:
                print(f"  ✅ Complete")
            print()


def has_audio_files(directory: Path) -> bool:
    """Check if directory contains any audio files."""
    if not directory.exists() or not directory.is_dir():
        return False

    audio_extensions = {'.flac', '.mp3', '.m4a', '.aac', '.wav'}
    for item in directory.iterdir():
        if item.is_file() and item.suffix.lower() in audio_extensions:
            return True
        elif item.is_dir():
            # Recursively check subdirectories
            if has_audio_files(item):
                return True
    return False


def remove_empty_directories(music_dir: Path, directory: Path, verbose: bool = True):
    """
    Remove directory if it contains no audio files, and recursively clean up parent directories.

    Args:
        music_dir: Root music directory (stop cleanup at this level)
        directory: Directory to check and potentially remove
        verbose: Whether to print removal messages
    """
    if not directory.exists() or not directory.is_dir():
        return

    # Don't remove the root music directory
    if directory == music_dir:
        return

    # Check if directory has any audio files (including in subdirectories)
    if has_audio_files(directory):
        return

    # Directory is empty of audio files - remove it
    try:
        directory.rmdir()
        if verbose:
            print(f"  🗑️  Removed empty directory: {directory}")

        # Recursively clean up parent directory
        parent = directory.parent
        if parent != music_dir:
            remove_empty_directories(music_dir, parent, verbose)
    except OSError:
        # Directory might not be empty (non-audio files) or permission issue
        pass


def operations_to_json(operations: List[Dict], music_dir: Path) -> Dict:
    """
    Convert operations to JSON-serializable format.

    Returns:
        Dictionary with operations, summary, and metadata
    """
    merge_to_main = [op for op in operations if op['type'] == 'merge_to_main']
    merge_to_various = [op for op in operations if op['type'] == 'merge_to_various']

    # Group merge_to_main by target album
    albums_by_target = defaultdict(list)
    for op in merge_to_main:
        key = (op['target_artist'], op['target_album'])
        albums_by_target[key].append(op)

    main_artist_ops = []
    for (target_artist, target_album), ops in albums_by_target.items():
        all_final_tracks = set()
        sources = []
        for op in ops:
            all_final_tracks.update(op['target_tracks'])
            all_final_tracks.update(op['tracks_to_move'])
            sources.append({
                'artist': op['source_artist'],
                'album': op['source_album'],
                'tracks_count': len(op['tracks_to_move']),
                'tracks': op['tracks_to_move']
            })

        final_tracks = sorted(all_final_tracks)
        op = ops[0]
        will_be_complete, _, missing_tracks = analyze_album_completeness(final_tracks)

        main_artist_ops.append({
            'target_artist': target_artist,
            'target_album': target_album,
            'sources': sources,
            'result_track_count': len(final_tracks),
            'result_tracks': final_tracks,
            'complete': will_be_complete,
            'missing_tracks': missing_tracks
        })

    compilation_ops = []
    for op in merge_to_various:
        source_artists = [{'artist': loc[0], 'album': loc[1]} for loc in op['source_locations']]

        compilation_ops.append({
            'target_artist': op['target_artist'],
            'target_album': op['target_album'],
            'sources': source_artists,
            'result_track_count': len(op['all_tracks']),
            'result_tracks': op['all_tracks'],
            'complete': op['will_be_complete'],
            'missing_tracks': op['missing_tracks']
        })

    return {
        'music_directory': str(music_dir),
        'total_operations': len(operations),
        'main_artist_consolidations': main_artist_ops,
        'compilation_consolidations': compilation_ops,
        'summary': {
            'main_artist_count': len(main_artist_ops),
            'compilation_count': len(compilation_ops),
            'total_albums_affected': len(main_artist_ops) + len(compilation_ops)
        }
    }


def execute_operations(music_dir: Path, operations: List[Dict], dry_run: bool = True):
    """Execute the consolidation operations."""
    if dry_run:
        print("\n🔍 DRY RUN MODE - No files will be moved\n")
        print_operation_summary(operations, dry_run=True)
        return

    print("\n🚀 EXECUTING OPERATIONS\n")

    for op in operations:
        if op['type'] == 'merge_to_main':
            source_dir = music_dir / op['source_artist'] / op['source_album']
            target_dir = music_dir / op['target_artist'] / op['target_album']

            # Ensure target directory exists
            target_dir.mkdir(parents=True, exist_ok=True)

            print(f"Moving tracks from {op['source_artist']}/{op['source_album']} to {op['target_artist']}/{op['target_album']}")

            for track in op['tracks_to_move']:
                source_file = source_dir / track
                target_file = target_dir / track

                if source_file.exists():
                    if target_file.exists():
                        print(f"  ⚠️  Skipping {track} - already exists in target")
                    else:
                        shutil.move(str(source_file), str(target_file))
                        print(f"  ✅ Moved {track}")
                else:
                    print(f"  ⚠️  {track} not found in source")

            # Remove empty directories (album and artist if empty)
            remove_empty_directories(music_dir, source_dir, verbose=True)
            remove_empty_directories(music_dir, music_dir / op['source_artist'], verbose=True)

        elif op['type'] == 'merge_to_various':
            target_dir = music_dir / op['target_artist'] / op['target_album']
            target_dir.mkdir(parents=True, exist_ok=True)

            print(f"Consolidating {op['target_album']} to {op['target_artist']}/")

            for artist, album in op['source_locations']:
                source_dir = music_dir / artist / album

                if not source_dir.exists():
                    continue

                print(f"  Moving from {artist}/{album}")

                for track_file in source_dir.iterdir():
                    if track_file.is_file() and track_file.suffix.lower() in ['.flac', '.mp3', '.m4a', '.aac', '.wav']:
                        target_file = target_dir / track_file.name

                        if target_file.exists():
                            print(f"    ⚠️  Skipping {track_file.name} - already exists")
                        else:
                            shutil.move(str(track_file), str(target_file))
                            print(f"    ✅ Moved {track_file.name}")

                # Remove empty directories (album and artist if empty)
                remove_empty_directories(music_dir, source_dir, verbose=True)
                remove_empty_directories(music_dir, music_dir / artist, verbose=True)

            print()

    # Final cleanup pass - remove any remaining empty directories
    print("🧹 Final cleanup pass...")
    removed_any = True
    while removed_any:
        removed_any = False
        for artist_dir in music_dir.iterdir():
            if artist_dir.is_dir() and not artist_dir.name.startswith('.'):
                if not has_audio_files(artist_dir):
                    try:
                        artist_dir.rmdir()
                        print(f"  🗑️  Removed empty directory: {artist_dir}")
                        removed_any = True
                    except OSError:
                        pass

    print("\n✅ Consolidation complete!")


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description='Organize Apple Music folder structure by consolidating split albums'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Preview changes without making them'
    )
    parser.add_argument(
        '--music-dir',
        type=str,
        default='/Volumes/media/TuneFab/Apple Music',
        help='Path to Apple Music directory (default: /Volumes/media/TuneFab/Apple Music)'
    )
    parser.add_argument(
        '--json',
        action='store_true',
        help='Output results in JSON format (useful for piping to other tools)'
    )

    args = parser.parse_args()

    music_dir = Path(args.music_dir)

    if not music_dir.exists():
        print(f"❌ Error: Music directory not found: {music_dir}")
        sys.exit(1)

    if not args.json:
        print(f"📂 Scanning music directory: {music_dir}")
        print("   This may take a moment...\n")

    # Scan structure
    structure = get_artists_and_albums(music_dir)

    if not args.json:
        print(f"✅ Found {len(structure)} artist(s) with albums\n")

    # Plan consolidations
    operations = plan_consolidations(music_dir, structure)

    # Output JSON if requested
    if args.json:
        json_output = operations_to_json(operations, music_dir)
        json_output['dry_run'] = args.dry_run
        print(json.dumps(json_output, indent=2))
        return

    # Execute (or dry-run)
    execute_operations(music_dir, operations, dry_run=args.dry_run)

    if args.dry_run and operations:
        print("\n💡 To apply these changes, run without --dry-run flag")


if __name__ == '__main__':
    main()
