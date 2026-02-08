#' Clean Up Unneeded Files from Working Directory
#'
#' This function provides a simple interface for quickly removing any of the output produced by scrivenR.
#' @param converted_audio Remove converted audio files? (default: FALSE)
#' @param transcripts Remove transcriptions exported as .TXT? (default: FALSE)
#' @param textgrids Remove .TextGrid files? (default: FALSE)
#' @keywords transcription, whisper, ASR, batch-processing, file removal
#' @export
#' @examples
#' cleanup(converted audio = FALSE, transcripts = FALSE, textgrids = FALSE)

cleanup <- function(converted_audio = FALSE, transcripts = FALSE, textgrids = FALSE) {

  file_vec <- list.files()

  if (converted_audio == FALSE & transcripts == FALSE & textgrids == FALSE) {
    stop("No files specified for removal. The function call has been halted. If you wish to use cleanup() for file deletion, please provide 'TRUE' for one or more of the following arguments: converted_audio, transcripts, textgrids.")
  }

  if (converted_audio == TRUE) {

    del_wav <- file_vec |>
      str_subset("_converted.wav$")

    choice <- menu(choices = c("Yes", "No"), title = paste0("Are you sure you want to permanently delete the following converted audio files?", "\n", del_wav ))

    if (choice==1L) {

      file.remove(del_wav)

      message(paste0("Permanently deleted ", length(del_trans), " converted .WAV from ", getwd()))
    }
    else {
      message("Cleanup of converted audio files has been canceled.")
    }


  }


  if (transcripts == TRUE) {

    del_trans <- file_vec |>
      str_subset("_transcript.txt$")

    choice <- menu(choices = c("Yes", "No"), title = paste0("Are you sure you want to permanently delete the following transcript files?", "\n", del_trans))

    if (choice==1L) {

      file.remove(del_trans)

      message(paste0("Permanently deleted ", length(del_trans), " .TXT files from ", getwd()))
    }
    else {
      message("Cleanup of transcripts has been canceled.")
    }

    }



  if (textgrids == TRUE) {

    del_tg <- file_vec |>
      str_subset(".TextGrid$")

    choice <- menu(choices = c("Yes", "No"), title = paste0("Are you sure you want to permanently delete the following TextGrid files?", "\n", del_tg))

    if (choice==1L) {

      file.remove(del_tg)

      message(paste0("Permanently deleted ", length(del_trans), " .TextGrid files from ", getwd()))
    }
    else {
      message("Cleanup of TextGrids has been canceled.")
    }


  }

}













