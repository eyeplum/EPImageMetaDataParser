EPImageMetaDataParser
=====================

Parse Image Metadata at a given URL with minimum data downloaded. Built for Mac and iOS.


How To Use
==========

1. Add files under `/EPImageMetaDataParser` to your project.
2. Link `ImageIO.framework` to your project.
3. Use `[EPImageMetaDataParser parseImageMetaDataWithURL:completionHandler:]` to parse image metadata.


TODO
====

+ Continue to fetch data after the fetch limit is reached if `EXIF marker` is found in image data. For more information about `EXIF marker`, see: http://www.media.mit.edu/pia/Research/deepview/exif.html