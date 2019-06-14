USE [dbASOMS_Validation]
GO

/****** Object:  View [validations].[vwMainReleaseFacts]    Script Date: 6/14/2019 2:12:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [validations].[shubhangTest] AS
select * from validations.fnMaterialDescriptionShouldBeginWithAZ() UNION
select * from validations.fnCheckPreviewEAPortalFriendlyName() UNION
select * from validations.fnNonGLLinkedCNMetersDevTest() UNION
select * from validations.fnCheckMeterUoMStartsWithANumber() UNION
select * from validations.fnCheckDiscontinueDatesBeforePLDate() UNION
select * from validations.fnCheckRevenueSKUOfMeterIsNotNull();

GO