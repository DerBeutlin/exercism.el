;;; exercism.el --- A package to interact with exercism.io

;; Copyright (C) 2019 Max Beutelspacher

;; Author: Max Beutelspacher <max.beutelspacher@mailbox.org>
;; URL: https://github.com/DerBeutlin/exercism.el
;; Version: 0.1
;; Package-Requires: ((emacs "25.1"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; A package to interact with exercism.io using the exercism cli

;;; Code:

(require 'dired)
(require 's)

(defgroup exercism nil "Related to the exercism client." :group 'external)

(defun exercism-command-to-string(cmd)
  "Run exercism CMD and return output as trimmed string."
  (s-trim (shell-command-to-string (concat "exercism " cmd))))


;;;###autoload
(defun exercism-submit-files(files)
  "Submit all the FILES to exercism.
If called interactively from dired, submit the marked files if there are any. Otherwise submit the file at point."
  (interactive (list (if (dired-get-marked-files) (dired-get-marked-files) '((dired-get-filename)))))
  (message (exercism-command-to-string (concat "submit " (mapconcat 'identity files " ")))))

;;;###autoload
(defun exercism-submit-current-buffer()
  "Submit the file the current buffer visits to exercism."
  (interactive)
  (exercism-submit-files (list (buffer-file-name))))

(defun exercism-completing-read-track()
  "Completing read function for `exercism-tracks'."
  (completing-read "Track: " (exercism-tracks)))

(defun exercism-completing-read-exercise()
  "Completing read function exercise."
  (downcase (read-string "Exercise: ")))

(defun exercism-workspace()
  "Return the path to the exercism workspace."
  (exercism-command-to-string "workspace"))

(defun exercism-tracks()
  "Return the list of tracks which are in the exercism-workspace."
  (seq-filter (lambda (dir) (not(seq-contains '("." ".." "users") dir))) (directory-files (exercism-workspace))))

;;;###autoload
(defun exercism-go-to-track-directory(track)
  "Visit the directory for TRACK in dired."
  (interactive (list (exercism-completing-read-track)))
  (let ((directory (concat (exercism-workspace) "/" track)))
    (if (file-directory-p directory)
        (dired directory)
      (error (concat "The directory for track " track "does not exist yet.")))))

;;;###autoload
(defun exercism-download-task (track exercise)
  "Download EXERCISE in TRACK and switch to readme of this exercise."
  (interactive (list (exercism-completing-read-track) (exercism-completing-read-exercise)))
  (exercism-command-to-string (format "download --track=%s --exercise=%s" track exercise))
  (let ((new-directory (concat (exercism-workspace) "/" track "/" exercise)))
    (if (file-directory-p new-directory)
        (find-file (concat new-directory "/" "README.md"))
      (error (format "Could not download the exercise %s in track %s." exercise track)))))


(provide 'exercism)

;;; exercism.el ends here
