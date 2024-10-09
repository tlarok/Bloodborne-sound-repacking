#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys

sys.dont_write_bytecode = True  # noqa: E402

import os
import shutil
import argparse
import concurrent.futures
import subprocess
import time

DEFAULT_THREAD_COUNT = 0
# Extensions to process in converter script
FSB_EXTENSION = ".fsb"
WAV_EXTENSION = ".wav"
MP3_EXTENSION = ".mp3"

# argument to VGM containing mask for output file
VGM_STREAM_WILDCARD_FILE = "?05s?n.wav"

# Default paths to converter executables
PATH_TO_VGM_STREAM = "vgstream/vgmstream-cli.exe"
PATH_TO_LAME = "lame/lame.exe"
PATH_TO_FMOD = "Fmod/fsbankcl.exe"

# Some tmp folders used while repacking

# Temp folder to store unpacked mp3/wav files
TEMP_FOLDER = "temp_folder"
# Fmod cached objects directory
FMOD_CACHE_FOLDER = "fmod_cache_folder"
# Subfolder to store converted banks
FSB_OUTPUT_FOLDER = "converted"

# Paths to converters
vgm_exe = ""
lame_exe = ""
fmod_exe = ""

# Vgm unpacking command. Launches in separate thread
def run_vgm_stream(input_file: str, out_dir: str):
    out_file = os.path.join(out_dir, VGM_STREAM_WILDCARD_FILE)
    command = vgm_exe + " -D 2 -S 0 -o " + out_file + " " + input_file
    with open('vgm_log.txt', "w+") as outfile:
        result = subprocess.call(command, stdout=outfile, stderr=outfile)
        return result

# Encoding wav to mp3 command. Launches in separate thread
def run_lame_encode(input_file: str, out_file: str):
    command = lame_exe + " -V 2 " + input_file + " " + out_file
    with open('lame_log.txt', "w+") as outfile:
        result = subprocess.call(command, stdout=outfile, stderr=outfile)
        return result

# Packing FSB from folder of mp3. Launches in separate thread
def run_fsb_pack(input_dir: str, out_file: str, cache_folder: str):
    command = (fmod_exe + " -o " + out_file + " " + input_dir +
               " -format mp3 -quality 25 -recursive -cache_dir " + cache_folder)
    with open('fmod_log.txt', "w+") as outfile:
        result = subprocess.call(command, stdout=outfile, stderr=outfile)
        return result

# Unpacking of FSB to set of WAV files.
def process_fsb_file(input_file: str, wav_output_dir: str):
    result_files = []
    # do unpacking
    process_result = run_vgm_stream(input_file, wav_output_dir)
    if process_result != 0:
        print('[VGM Stream] Error processing file ' + input_file + " error code is " + result)
    for root, _, files in os.walk(wav_output_dir):
        for wav_file in files:
            if wav_file.endswith(WAV_EXTENSION):
                # get group name as first 5 characters of file name
                group_name = wav_file[:5]
                # the rest is file name
                new_name = wav_file[5:]

                old_name = os.path.join(root, wav_file)
                # create subdir from group_name
                new_dir = os.path.join(root, group_name)
                os.mkdir(new_dir)

                # rename the file
                new_name = os.path.join(new_dir, new_name)
                os.rename(old_name, new_name)
                result_files.append(new_name)
    # Returns list of wav files for further encoding
    return result_files

# Converts wav to mp3
def process_wav_file(input_file: str, output_file: str):
    result = run_lame_encode(input_file, output_file)
    if result != 0:
        print('[Lame encode] Error processing file ' + input_file + " error code is " + result)
    os.remove(input_file)
    return result

# Gathers folder of mp3 sounds back to FSB archive
def process_mp3_file(input_folder: str, output_file: str, cache_folder: dir):
    result = run_fsb_pack(input_folder, output_file, cache_folder)
    if result != 0:
        print('[FMod pack] Error processing folder ' + input_folder + " error code is " + result)
    # Folder is packed to FSB, we can safely delete it now
    clean_temp_folder(input_folder)
    return result

# Utility function to clean up some folders
def clean_temp_folder(folder: str):
    if os.path.exists(folder):
        shutil.rmtree(folder)

# Gathers all *.FSB files in input dir
def collect_fsb_files(input_dir: str):
    result = []
    for root, sub_dirs, files in os.walk(input_dir):
        for file in files:
            if file.endswith(FSB_EXTENSION):
                result.append(os.path.join(root, file))

    return result

# Simple progressbar to keep track of convertion progress
def progress_bar(current, total, bar_length=20):
    fraction = current / total

    arrow = int(fraction * bar_length - 1) * '-' + '>'
    padding = int(bar_length - len(arrow)) * ' '

    ending = '\n' if current == total else '\r'

    print(f'Progress: [{arrow}{padding}] {int(fraction * 100)}%', end=ending)

# Ensures converter is configured properly before starting any meaningful work
def check_args(args):
    # Check if input dir is valid
    input_dir = args.input_dir
    if not os.path.exists(input_dir):
        print("Input dir not found: " + input_dir)
        return -1

    # Check if converters exist
    if not os.path.exists(args.vgmstream):
        print("vgmstream-cli.exe not found at: " + args.vgmstream + ". Please set correct path to vgmstream-cli.exe")
        return -1
    if not os.path.exists(args.lame):
        print("lame.exe not found at: " + args.lame + ". Please set correct path to lame.exe")
        return -1
    if not os.path.exists(args.fmod):
        print("fsbankcl.exe not found at: " + args.fmod + ". Please set correct path to fsbankcl.exe")
        return -1
    return 0


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Converts FMOD form wav to mp3")
    parser.add_argument('--input_dir', '-i', help='Directory with original files')
    parser.add_argument('--threads', '-t', help='Number of concurrent threads', default=str(0))
    parser.add_argument('--lame', '-l', help='Path to lame mp3 converter', default=PATH_TO_LAME)
    parser.add_argument('--vgmstream', '-v', help='Path to vgmstream unpacker', default=PATH_TO_VGM_STREAM)
    parser.add_argument('--fmod', '-f', help='Path to FMOD packer', default=PATH_TO_FMOD)

    # Set up args
    args = parser.parse_args()

    check_args_result = check_args(args)

    # If config is incorrect - it's better to leave now
    if check_args_result != 0:
        print('Incorrect arguments. Exiting')
        exit(-1)

    # Reading input from command args
    default_thread_count = os.cpu_count()
    if default_thread_count is None:
        default_thread_count = 1

    threads_count = 0
    try:
        threads_count = int(args.threads)
        # if thread count is not set - we 'll use all available cores
        if threads_count == 0:
            threads_count = default_thread_count
    except ValueError:
        threads_count = DEFAULT_THREAD_COUNT

    threads_count = min(default_thread_count, threads_count)
    source_dir = args.input_dir
    output_dir = os.path.join(source_dir, FSB_OUTPUT_FOLDER)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    print("Output directory: " + output_dir)

    if os.listdir(output_dir):
        print("Output dir is not empty: " + output_dir + ". Please clean it before running script to avoid losing data.")
        exit(0)

    vgm_exe = args.vgmstream
    lame_exe = args.lame
    fmod_exe = args.fmod

    tasks = []
    print("Available threads count: " + str(threads_count))

    start_time = time.time()

    print("Collecting *.fsb files in directory: " + source_dir, flush=True)

    # Gather *.FSB in input dir
    fsb_file_list = collect_fsb_files(source_dir)
    fsb_total = len(fsb_file_list)
    fsb_count = 0

    print("Found " + str(fsb_total) + " files to process", flush=True)
    print("Unpacking FSB files", flush=True)

    # Unpacking FSB
    progress_bar(fsb_count, fsb_total)
    wav_files = []
    unpacked_banks = []
    converted_temp_folder = os.path.join(output_dir, TEMP_FOLDER)
    if not os.path.exists(converted_temp_folder):
        os.makedirs(converted_temp_folder)

    # Run unpacking via ThreadPool
    with concurrent.futures.ThreadPoolExecutor(max_workers=threads_count) as pool:
        for file in fsb_file_list:
            file_name = os.path.basename(file)
            file_without_extension = os.path.splitext(file_name)[0]
            wav_output_dir = os.path.join(converted_temp_folder, file_without_extension)
            # Preparing directories in main thread to avoid errors
            if not os.path.exists(wav_output_dir):
                os.makedirs(wav_output_dir)
            unpacked_banks.append([file_without_extension, wav_output_dir])
            task = pool.submit(process_fsb_file, file, wav_output_dir)
            tasks.append(task)

        # Run the jobs and update the progress
        done = False
        while not done:
            done_tasks, all_tasks = concurrent.futures.wait(tasks, return_when=concurrent.futures.FIRST_COMPLETED)
            fsb_count = len(done_tasks)
            progress_bar(fsb_count, fsb_total)
            done = len(all_tasks) == 0

            if done:
                for task in done_tasks:
                    result = task.result()
                    wav_files.extend(result)

    wav_total = len(wav_files)
    wav_count = 0

    print("Unpacked " + str(wav_total) + " WAV files ", flush=True)
    print("Processing wav to mp3", flush=True)
    progress_bar(wav_count, wav_total)
    tasks = []

    # Converting wav to Mp3
    with concurrent.futures.ThreadPoolExecutor(max_workers=threads_count) as pool:
        for file in wav_files:
            file_dir = os.path.dirname(file)
            file_name = os.path.basename(file)
            file_without_extension = os.path.splitext(file_name)[0]
            out_file = os.path.join(file_dir, file_without_extension + MP3_EXTENSION)

            task = pool.submit(process_wav_file, file, out_file)
            tasks.append(task)

        # Run the jobs and update the progress
        done = False
        while not done:
            done_tasks, all_tasks = concurrent.futures.wait(tasks, return_when=concurrent.futures.FIRST_COMPLETED)
            wav_count = len(done_tasks)
            progress_bar(wav_count, wav_total)
            done = len(all_tasks) == 0

    print("Packing mp3 to FSB", flush=True)


    # Setting up directories for final packing to FSB
    tasks = []
    fsb_output_dir = output_dir
    fsb_cache_dir = os.path.join(output_dir, FMOD_CACHE_FOLDER)
    if not os.path.exists(fsb_output_dir):
        os.makedirs(fsb_output_dir)
    if not os.path.exists(fsb_cache_dir):
        os.makedirs(fsb_cache_dir)

    fsb_count = 0
    progress_bar(fsb_count, fsb_total)
    # Run packing in threads
    with concurrent.futures.ThreadPoolExecutor(max_workers=threads_count) as pool:
        for bank in unpacked_banks:
            output_file, fsb_input_dir = bank
            output_file_name = os.path.join(fsb_output_dir, output_file + FSB_EXTENSION)

            task = pool.submit(process_mp3_file, fsb_input_dir, output_file_name, fsb_cache_dir)
            tasks.append(task)

        done = False
        while not done:
            done_tasks, all_tasks = concurrent.futures.wait(tasks, return_when=concurrent.futures.FIRST_COMPLETED)
            fsb_count = len(done_tasks)
            progress_bar(fsb_count, fsb_total)
            done = len(all_tasks) == 0

    print("Packing completed", flush=True)
    print("Repacked files stored in " + fsb_output_dir, flush=True)

    # Clean up all the temp stuff
    print("Cleaning temp folders", flush=True)
    clean_temp_folder(converted_temp_folder)
    clean_temp_folder(fsb_cache_dir)

    elapsed_time = (time.time() - start_time)
    print("Elapsed time: {0}".format(
        time.strftime("%H:%M:%S.{}".format(str(elapsed_time % 1)[2:])[:15], time.gmtime(elapsed_time))))

