;;; cont-save.el --- Continuous file saving like Intellij IDEA  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Xingchen Ma

;; Author: Xingchen Ma <maxc01@yahoo.com>
;; Keywords: tools, save

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; `cont-save' continuously saves the current buffer.

;;; Code:

(defvar cont-save-mode)
(defvar cont-save-mode-lighter " cont-save"
  "Mode line lighter for cont-save mode.")

(defgroup cont-save nil
  "Continuously save the current buffer."
  :group 'convenience)

(defcustom cont-save-exclude-buffers '("\\.gpg\\'")
  "List of buffers that should be excluded."
  :type '(restricted-sexp :match-alternatives (stringp symbolp))
  :group 'cont-save)

(defvar cont-save--exclude-names nil
  "List of buffer names that should be excluded.")

(defvar cont-save--exclude-modes nil
  "List of major-modes that should be excluded.")

(defun cont-save--exclude-p (buf)
  "Predicate to test if a buffer BUF should be excluded or not."
  (or (seq-some (lambda (buf-regexp)
                  (string-match-p buf-regexp (buffer-name buf)))
                cont-save--exclude-names)
      (member (buffer-local-value 'major-mode buf) cont-save--exclude-modes)))

(defun cont-save--save-buffer (_beg _end _len)
  "Save current buffer."
  (when (and buffer-file-name
             (buffer-modified-p (current-buffer))
             (file-writable-p buffer-file-name)
             (not (cont-save--exclude-p (current-buffer))))
    (let ((save-silently t))
      (save-excursion
        (save-match-data
          (save-buffer))))))

;;;###autoload
(define-minor-mode cont-save-mode
  "Toggle cont-save minor mode."
  :global t
  :lighter cont-save-mode-lighter
  :group 'cont-save
  :keymap (let ((map (make-sparse-keymap))) map)
  (if cont-save-mode
      (progn
        (setq cont-save--exclude-names
              (cl-remove-if-not #'stringp cont-save-exclude-buffers)
              cont-save--exclude-modes
              (cl-remove-if-not #'symbolp cont-save-exclude-buffers))
        (add-hook 'after-change-functions #'cont-save--save-buffer))    
    (remove-hook 'after-change-functions #'cont-save--save-buffer)))


(provide 'cont-save)
;;; cont-save.el ends here
