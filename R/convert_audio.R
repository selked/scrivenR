#' Convert Audio File to 16-bit Mono .WAV
#'
#' This function takes a list of files, filters by common audio file extensions, and then runs an ffmpeg command to convert the audio and write output to the working directory.
#' @param x Output of list.files() in working directory containing videos
#' @keywords audio conversion
#' @export
#' @examples
#' convert_audio(list.files())

convert_audio <- function (x) {

  audio_formats <- c(".wav", ".mp3", ".aiff", ".m4a")

  audio_files <- str_subset(
    x,
    paste0(audio_formats,
    collapse = '|'))

  if (length(audio_files)==0) {
    print("No recognizable audio files in working directory. Add your files, convert to allowable audio formats, or change to appropriate directory.")
  }

  else {

    for (file in audio_files) {

      print(paste0("Converting ", file, " to 16-bit mono"))


      tic()
      system(paste0("ffmpeg -i ", file, " -acodec pcm_s16le -ac 1 -ar 16000 ", file_path_sans_ext(file), "_converted.wav" ), show.output.on.console = FALSE)
      toc()

    }
    print(paste0("Audio conversion completed. Output located in ", getwd()))
  }


}
