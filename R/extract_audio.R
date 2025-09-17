#' Extract Audio File from Video
#'
#' This function takes a list of files, filters by common video file extensions, and then runs an ffmpeg command to extract the audio and write output to the working directory.
#' @param x Output of list.files() in working directory containing videos
#' @keywords audio conversion, audio extraction
#' @export
#' @examples
#' extract_audio(list.files())

extract_audio <- function (x) {

  video_formats <- c(".mp4", ".mkv", ".avi", ".mpeg", ".mpg")

  video_files <- str_subset(
    x,
    paste0(video_formats,
    collapse = '|'))

  if (length(video_files)==0) {
    print("No recognizable video files in working directory. Add your files, convert to allowable video formats, or change to appropriate directory.")
  }

  else {

  for (file in video_files) {

    print(paste0("Extracting audio from ", file, " and converting to 16-bit mono"))


    tic()
    system(paste0("ffmpeg -i ", file, " -vn -ac 1 -ar 16000 -f wav ", file_path_sans_ext(file), "_converted.wav" ), show.output.on.console = FALSE)
    toc()

    }
    print(paste0("Audio extraction completed. Output located in ", getwd()))
  }


}
