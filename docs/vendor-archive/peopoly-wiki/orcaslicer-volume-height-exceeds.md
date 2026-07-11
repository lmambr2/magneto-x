---
source: https://wiki.peopoly.net/en/magneto/magneto-x/orcaslicer-volume-height-exceeds
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/orcaslicer-volume-height-exceeds
> Content may be outdated or wrong; prefer community docs when they disagree.

Tips for Bounding Box Error in OrcaSlicer When Importing and Slicing Large Models | Peopoly Wiki - - - - - - - -

# [¶](#workaround-for-bounding-box-error-in-orcaslicer-when-importing-and-slicing-large-models) Workaround for Bounding Box Error in OrcaSlicer When Importing and Slicing Large Models

 When a model is imported, its bounding box initially exceeds the print size (300x400x300). However, after rotating, aligning, and transforming its position, the bounding box no longer exceeds the printing range. Despite this, an error still occurs during the slicing process:

 Solution:

 Currently, OrcaSlicer is working on fixing this bug. Until it is fully resolved, if we encounter a similar issue, we can avoid the problem by following these steps:

-
 Import the large model to be printed into OrcaSlicer, then reposition and align the model.

-
 Export the repositioned model as an STL file, saving it in a specified location.

-
 Re-import the model exported in the previous step into the slicing software and proceed with slicing.

 The above method can circumvent the error message.
