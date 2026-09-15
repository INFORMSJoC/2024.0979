# HDR-BT 3D-Printed Mask DICOM Data

## Overview

This package documents the clinical DICOM-RT objects and manuscript materials associated with:

> Mirzavand Boroujeni, N., Richard, J.-P. P., Sterling, D., and Wilke, C.  
> *Optimization models for needle placement in 3D-printed masks for high-dose-rate brachytherapy.*  
> Manuscript submitted to *INFORMS Journal on Computing*.

The study develops fixed-needle mixed-integer programming (MIP) and free-needle MIP/mixed-integer nonlinear programming (MINLP) methods to design straight channels in patient-specific, 3D-printed surface masks for high-dose-rate brachytherapy (HDR-BT) of superficial skin cancer. The manuscript evaluates the methods retrospectively on three clinical cases: Nasal Case 1, Nasal Case 2, and Ear Case.

This README is a data descriptor for research and reproducibility.



### Intended source attribution

The data were derived from retrospective HDR-BT cases managed through the Department of Radiation Oncology, University of Minnesota, as described in the associated manuscript.


## Privacy, Governance, and Release Status


The supplied files are anonymized DICOM-RT structure sets and treatment. All direct and indirect identifiers, including patient identifiers, dates/times, UIDs, nested-sequence content, and vendor private attributes, are removed or transformed in accordance with applicable institutional policy.

Facial anatomy outside the tumor and non-tumor regions are removed, subject to clinical and institutional review, to mitigate facial-reconstruction risk. Requests for access to the complete data must be discussed with the authors and are subject to institutional agreement.


## DICOM file content sample


The provided samples illustrate common data fields; individual DICOM files may contain additional fields or different available data.

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
| `ApprovalStatus` | Workflow status.|
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
| `ChannelLength` | Encoded channel length.|
| `BrachyControlPointSequence` | Dwell/control-point positions and timing information. |
| `ChannelTotalTime` | Encoded total channel time. |
| `FractionGroupSequence` | Fractionation and application-setup counts. |
| `SourceSequence` | Source isotope and source-strength metadata. |
