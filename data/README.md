# HDR-BT 3D-Printed Mask DICOM Data

## Overview

This package documents the clinical DICOM-RT objects and manuscript materials associated with:

> Mirzavand Boroujeni, N., Richard, J.-P. P., Sterling, D., and Wilke, C.  
> *Optimization models for needle placement in 3D-printed masks for high-dose-rate brachytherapy.*  
> Manuscript submitted to *INFORMS Journal on Computing*.

The study develops fixed-needle mixed-integer programming (MIP) and free-needle MIP/mixed-integer nonlinear programming (MINLP) methods to design straight channels in patient-specific, 3D-printed surface masks for high-dose-rate brachytherapy (HDR-BT) of superficial skin cancer. The manuscript evaluates the methods retrospectively on three clinical cases: Nasal Case 1, Nasal Case 2, and Ear Case.

This README is a data descriptor for research and reproducibility.



### Intended source attribution

The data were derived from retrospective HDR-BT cases managed through the Department of Radiation Oncology, University of Minnesota, as described in the associated manuscript. The manuscript's authors include contributors from the University of Minnesota Department of Industrial and Systems Engineering, the University of Minnesota Department of Radiation Oncology, and the University of Pittsburgh Department of Radiation Oncology.


## Privacy, Governance, and Release Status


The supplied files are anonymized DICOM-RT structure sets and treatment. All direct and indirect identifiers, including patient identifiers, dates/times, UIDs, nested-sequence content, and vendor private attributes, are removed or transformed in accordance with applicable institutional policy.

Facial anatomy outside the tumor and non-tumor regions are removed, subject to clinical and institutional review, to mitigate facial-reconstruction risk. Requests for access to the complete data must be discussed with the authors and are subject to institutional agreement.


## DICOM file content sample



| Case label inferred from filename | Recommended filename | SOP class / modality | Size (bytes) | SHA-256 |
| --- | --- | --- | ---: | --- |
| Ear Case | `RS_anon_roi_ear_case_body_structure.dcm` | RT Structure Set Storage / `RTSTRUCT` | 142,364 | `a28146654d8764426a6733c792f1902ee8165539dd4853cb634bc6a869800820` |
| Nasal Case 1 | `nose1_needles.dcm` | RT Plan Storage / `RTPLAN` | 10,826 | `e8221010837a4bf55f12b06e9ff3a4a400182448e295156cc74888dd1f84a6bb` |
| Nasal Case 1 | `RS_anon_roi_nose_1_case_body_structure.dcm` | RT Structure Set Storage / `RTSTRUCT` | 84,870 | `aa626a43c31f0ce5bb8162abba5346439f3c0ce4afcc075f693c0d2d3f325dda` |
| Nasal Case 2 | `RS_anon_roi_nose_2_case_body_structure.dcm` | RT Structure Set Storage / `RTSTRUCT` | 143,296 | `687403754043d14b55cc85b240e0c12e45ea96bc7a540b7e25ebef6ded9183ac` |
| Nasal Case 2 | `nose_2_needles.dcm` | RT Plan Storage / `RTPLAN` | 7,920 | `b3d263cc88090b4891e3f9dc057074ce8601f04710548b9806f28d1df94533e4` |
| Ear Case | `ear_needles.dcm` | RT Plan Storage / `RTPLAN` | 7,462 | `d0327dcb8040aca99eadcba003384798a3d0b76866a82f317cbe3713fa69f5b4` |

All six inspected files use Explicit VR Little Endian transfer syntax and `ISO_IR 100` character encoding. The producer metadata identifies Nucletron Oncentra; this is file provenance metadata, not a statement of clinical-system validation.

## Data Dictionary

### Common DICOM fields

| Field | Present in | Meaning / use |
| --- | --- | --- |
| `SOPClassUID` | All files | Identifies the DICOM object class. Values correspond to RT Structure Set Storage or RT Plan Storage. |
| `Modality` | All files | Object modality: `RTSTRUCT` or `RTPLAN`. |
| `Manufacturer` | All files | Planning-system manufacturer metadata. |
| `ManufacturerModelName` | All files | Planning-system model metadata. |
| `SoftwareVersions` | All files | Planning-system software version. |
| `SpecificCharacterSet` | All files | Character encoding; `ISO_IR 100` in the reviewed files. |
| `SOPInstanceUID` | All files | Unique object identifier. Do not disclose unchanged UIDs in a public release. |
| `FrameOfReferenceUID` | Plans / referenced structures | Spatial frame identifier. It must be consistent with the released image and structure objects. |
| `PatientIdentityRemoved` | Not populated | Standard de-identification declaration; must be populated by a validated release workflow. |
| `DeidentificationMethod` | Not populated | Documents the de-identification method; must be populated by a validated release workflow. |

### RT Structure Set fields

| Field | Meaning / use |
| --- | --- |
| `StructureSetLabel` | Short structure-set label. |
| `StructureSetName` | Structure-set name. |
| `StructureSetROISequence` | Defines ROI number, name, and referenced frame of reference. |
| `ROINumber` | Integer ROI identifier used for cross-references within the object. |
| `ROIName` | Human-readable ROI label. |
| `ROIContourSequence` | Contour geometry for each referenced ROI. |
| `ContourSequence` | Individual planar contour items and their coordinates. |
| `RTROIObservationsSequence` | ROI interpretation/observation information. |
| `ReferencedROINumber` | Links contour or observation records to `ROINumber`. |
| `ReferencedFrameOfReferenceSequence` | Links structures to the imaging frame and referenced image series. |

### RT Plan fields

| Field | Meaning / use |
| --- | --- |
| `RTPlanLabel` | Plan label. |
| `RTPlanName` | Optional plan name. |
| `ApprovalStatus` | Workflow status. It is not evidence that a plan is clinically approved for use. |
| `RTPlanGeometry` | Whether plan geometry is patient-based. |
| `DoseReferenceSequence` | Dose-reference constraints and/or points. |
| `DoseReferenceType` | Dose-reference category, such as target or organ at risk. |
| `TargetMinimumDose` | Target minimum-dose value when encoded. |
| `TargetMaximumDose` | Target maximum-dose value when encoded. |
| `OrganAtRiskLimitDose` | OAR limit when encoded. |
| `ApplicationSetupSequence` | Brachytherapy applicator/setup definition. |
| `ApplicationSetupType` | Setup type as encoded by the planning system. |
| `ChannelSequence` | One item per brachytherapy channel/needle. |
| `ChannelNumber` | Channel identifier within the application setup. |
| `ChannelLength` | Encoded channel length. Confirm the vendor's units and semantics before analysis. |
| `BrachyControlPointSequence` | Dwell/control-point positions and timing information. |
| `ChannelTotalTime` | Encoded total channel time. Confirm units and delivery semantics before analysis. |
| `FractionGroupSequence` | Fractionation and application-setup counts. |
| `SourceSequence` | Source isotope and source-strength metadata. |
