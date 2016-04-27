# SMD-Manual-Place-Image-Generator
This started as a Perl script to generate images to help manual pick and place of SMD components.
It needs the ImageMagick perl module, it works on my Ubuntu 14.04 server but I couldn't make the ImageMagick module work on my windows 10 PC (tried with 32 and 64 bits versions of strawberry-perl 5.20.3.2 and ImageMagick 6.9.3-3)

When I build a small amount of electronic boards that have SMD components, I find useful to have images on my tablet showing me the name, value and position of the components.

This script automatically generates the images using an image of the board and a CSV file of the components names, positions, values and packages.

### Here's how to use it with a board designed in Cadsoft Eagle:
- Export an image of the board
  - Ensure the lower left corner of your board has 0,0 coordinates, else move it
  - Select the layers you want to show (I use 17, 18, 20, 21, 25, 31, no grid), make sure component orientation is showing.
  - Export the image (The script assumes 300ppp this can be changed in the first lines of the script)
  - Crop the image to the board dimensions if needed (Eagle tends to add space around the board, get rid of that or the placement will be off)
- Export the components positions
  - On the schematic run the Electrical Rule Check and add missing values to the components that don't have one
  - Run the mountsmd ULP, we want the file with the MNT extension
- Run the script: ManualPlace.pl Power.mnt PowerC.png

The script will create an Assembly folder (it'll ask before clearing it if it already exists) and generate the images in it.

#### This is my very first Perl script, remarks, ideas and improvements very welcome.
