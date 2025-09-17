# scrivenR

## Introduction

This package provides a few convenience functions for batch-processing of audio conversion and automatic transcription. Though we need to hand-check the output of any transcript produced this way, doing so is often much less time-consuming than producing one from scratch. The goal of this package is to help create a simple pipeline for working with multiple recordings using tools available (or operable) in R. Each function takes a list of files, filters this list according to common files types, and then iteratively processes each file according to the function's procedure.

Automatic transcription is performed with [Whisper](https://github.com/openai/whisper). I do most of my work in R, which includes the excellent [`audio.whisper`](https://community.r-multiverse.org/audio.whisper/doc/manual.html) package. This allows for easy transcription of individual audio files, but I wanted some ready-made functions for batch processing of file-conversion and automatic transcription. That's where `scrivenR` comes in.

This package comprises three functions: `extract_audio()`, `convert_audio()`, and `transcribe_audio()`. Because Whisper requires its audio input to be formatted as 16-bit mono .WAVs, we often need to convert our audio files accordingly. The first two functions help us with this task, depending on whether we start with a video file or an inappropriately formatted audio files. The third function---assuming that we have now have the correct file formatting---will iterate through our list of files, automatically transcribe each recording, and write the output to a .txt file in the working directory.

Now, I'll explain some of the prerequisites and give a few working examples of each function.

## Prerequisites

### Installation & Package dependencies
You will want to make sure you have the following packages installed and loaded:

-   dplyr
-   stringr
-   readr
-   audio.whisper
-   parallel
-   tools

You can download `scrivenR` by running `devtools::install_github("selked/scrivenR")`.

### Download Whisper Acoustic Model

A major convenience of Whisper's is that it is open-source and thus allows us to freely download its acoustic model and use it from our local device. This is especially helpful in the case that we want transcriptions of recordings that include sensitive data, which we do not want to send through any third-party servers. This also allows us the convenience of running transcriptions completely offline.

So, before working with the package, you should make sure that you have a copy of the Whisper model you want to use. Luckily, we can do this easily with the `audio.whisper()` package.

Note that I'm including instructions for downloading the `base.en` model, which is only one of many options. [See here](https://community.r-multiverse.org/audio.whisper/doc/manual.html#whisper_download_model) for more detail. If you know your data is exclusively in English, opt for an English-only model, as performance appears optimized in these contexts. Otherwise, choose a model-size that makes sense for your system. I'm running on a pretty basic Dell laptop with an i5 intel core and 16 GB of RAM, and it took about 30-40 minutes to transcribe an hour-long recording using the base model (which had pretty good OOTB accuracy). As expected, transcription accuracy increases with model size, while transcription speed decreases correspondingly. I recommend starting with one of the smaller models and see how it works, and then go from there.

```{r, eval=FALSE}
library(audio.whisper)

setwd("C:/username/whispermodel") # Change to the place you'd like to store your model

model <- whisper("base.en")
```

The first time you run this, it will both download the model to your device and load it into your R session. After this first time, you can load it into your R session without re-downloading the model by using the same `audio.whisper` function while providing the file path to your local model rather than the generic model title, e.g:

```{r, eval=FALSE}
model <- whisper("C:/username/whispermodel/ggml-base.en.bin")
```

Once you have that situated, there's one more important prerequisite.

### Download Command-Line Program FFmpeg

In order to extract audio from videos or convert files in other audio formats, this package uses ffmpeg. This is a lightweight but extremely powerful audio and video processing program that is run entirely from the command-line or terminal.

I'll mention that R does have the very neat `av()` package, which binds R with ffmpeg, but I haven't always had the best luck with longer (1 hr+) files. Your mileage may well vary, so feel free to try it out, but I found that files taking me upwards of 45 minutes to convert with `av()` could be converted in seconds with ffmpeg.

So, if you want to make use of `extract_audio` or `convert_audio`, you will need to make sure you have ffmpeg installed. I leverage R's `system()` function to call ffmpeg commands using your file names. You can download ffmpeg [here](https://www.ffmpeg.org/download.html). I'm on Windows, and I typically download the most recent, stable 'full' build from gyan.dev. Make sure that the location of your ffmpeg bin file is added to your PATH system environment variable.

## Example Code for Functions

Now that we have our prerequisites settled, we'll take a look at some of these functions and their intended workflows.

But, before we begin, note that the `transcribe_audio()` function assumes your files will be formatted with 4 numbers, where an underscore separates two numbers on each side, e.g. `08_10.mp4`. I will probably customize this further in future updates, but I designed it to meet an initial case where files were labeled in 'month_day\` format.

This allows for some customization in itself, but, in any case, make sure that whatever files you start with for the functions below are named in this `12_34` format.

### extract_audio()

This is the function you want if you are starting with a video file, and you need a transcription of the audio. FFmpeg allows us to cleanly extract the audio and convert it to our required format with a single command, so we can do this pretty easily.

The only argument for this function is a character vector of file names. I typically set my working directory to the file containing my videos, and then just provide the output of `list.files()`. You can have other files in this directory, as the function will filter files according to common video-format extensions, but make sure that any video in the directory is one from which you want to have audio extracted.

This function will output an audio file for each video in your working directory, and the file naming convention is `originalFileName_converted.wav`.

**Accepted file formats:** 
-   .mkv 
-   .mp4 
-   .avi 
-   .mpeg

**Example:**
```{r, eval=FALSE}
setwd("C:/username/Desktop/video_files")

extract_audio(list.files())
```

### convert_audio()

The architecture of this function is very similar to `extract_audio()`, but it is intended for use when you already have audio files and need them converted to Whisper's required 16-bit mono .WAV format. Provide a character vector of file names in the directory containing your audio files, and the function will filter by common audio-format extensions and, for each file, output `originalFileName_converted.wav`.

**Accepted file formats:** 
-   .wav 
-   .mp3 
-   .aiff 
-   .m4a

**Example:**
```{r, eval=FALSE}
setwd("C:/username/Desktop/audio_files")

convert_audio(list.files())
```

### transcribe_audio()

This function is the main thrust of the package, and it iterates through each of your appropriately formatted audio files and outputs a .txt containing the transcribed audio to your working directory.

As opposed to the first two functions, this one has multiple arguments.

-   ***`x`:*** A character vector of file names in your working directory
-   ***`include_timing`:*** An option to specify whether you want line-by-line timestamps recorded in your output. This is set to `FALSE` by default.
-   ***`internal_convert`:*** An option to indicate whether your audio files were converted with functions internal to this package. This will take the `originalFileName_converted` re-naming format into account when filtering files in your directory for the transcription pipeline and is set to `TRUE` by default.
-   ***`model_path`:*** A character vector of the path to your locally stored Whisper acoustic model. This argument is required and should look like `"C:/username/whispermodel/ggml-base.en.bin"`, but with your own directory- and model-specific information.
-   ***`all_cores`:*** An option to indicate whether you want to utilize all of your CPU cores in parallel processing of the transcriptions. This is set to `FALSE` by default, wherein only half of your available cores will be used. If set to `TRUE`, parallel processing will include all CPU cores. I've found using all available cores to be pretty manageable, but note that it can slow some other things down while it's running.

**Example:**
```{r, eval=FALSE} 
setwd("C:/username/Desktop/files_to_be_transcribed")

mp <- "C:/username/whispermodel/ggml-base.en.bin"

transcribe_audio(
x = list.files(), 
include_timing = FALSE, 
internal_convert = TRUE, 
model_path = mp,
all_cores = FALSE)
```
