1. **Image resizing**: Use software like Photoshop and GIMP only when you’re doing something to the image, like cropping etc. Otherwise, you can use a single command for resizing images. It saves you a lot of time.

        convert -resize 300 image.jpg image-small.jpg

2. **Drop Shadow**: There is again a command for this. Adding a drop shadow doesn’t always need a graphical user interface to be working alongside it. In order to use the command, you must install Imagemagick on the system. On Debian and Ubuntu, this can be done using the apt-get install imagemagick command.

        convert screenshot.jpg \( +clone -background black -shadow 60×5+0+5 \) +swap -background white -layers merge +repage shadow.jpg

3. **Splice mp3 files**: Use the cat command to splice two mp3 files together.

        cat 1.mp3 2.mp3 > combined.mp3

4. **Cloning Hard Drives**: Rather than using a GUI, you can use DD, which is amongst the most powerful and simple image applications.

        dd if=/dev/hda of=/dev/hdb

5. **Burning an ISO image to a CD**: CD Burning software is good, but they have a lot of steps and take time. Use the following command instead. It is a big one, so use an alias instead.

        cdrecord -v speed=8 dev=0,0,0 name_of_iso_file.iso

    Note: In order to find the information for the `dev =` but, you can use the `cdrecord –scanbus` command.

6. **Video Conversions**: If you want to convert an AVI file into an MPEG file, then use the ffmpeg command.

        ffmpeg -i video_original.avi video_finale.mpg

    Same can be done for MPEG to AVI.

7. **Replacing words in a text file**: Use the sed command for this.

        sed ‘s/#FF0000/#0000FF/g’ main.css
