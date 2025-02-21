-- ================================================
-- Template generated from Template Explorer using:
-- Create Multi-Statement Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi, Shubhang
-- Create date: 15 July 2019
-- Description:	Meter Graduate rates should tier downwards
--				More details here: https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/89
-- =============================================


CREATE FUNCTION [validations].[fnCheckGraduatedRatesForMeters]
(
	
)
RETURNS @rtnTable TABLE (
	[Event ID] INT NULL,
	[Work Item Type] nvarchar(max) null,
	[Work Item ID] INT NULL,
	[Validation Name] nvarchar(max) NOT NULL,	
	[Flagged Column Name] nvarchar(max) NULL,
	[Flagged Column Value] nvarchar(max) null,
	[Remarks] nvarchar(max) NULL,
	[SKU State] nvarchar(max) NULL,	
	[SAP Rate Start Date] datetime NULL,
	[Cayman Release] nvarchar(max) NULL,	
	[Meter Status] nvarchar(max) NULL	
	
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT INTO @rtnTable
SELECT 
[Event ID] = e.[ID],
[Work Item Type] = 'Meter',
	[Work Item ID] = m.[MeterID],	
	[Validation Name] = 'Graduated meter rates should tier downward',	
	[Flagged Column Name] = CASE 
                            WHEN ( m.[Direct Rate] <= m.[Graduated Tier 1 Discount Rate] )THEN 'Direct Rate'  
                            WHEN (m.[Graduated Tier 1 Discount Rate] <= m.[Graduated Tier 2 Discount Rate]) THEN 'Graduated Tier 1 Discount Rate'
                            WHEN (m.[Graduated Tier 2 Discount Rate] <= m.[Graduated Tier 3 Discount Rate]) THEN 'Graduated Tier 2 Discount Rate'
                            WHEN (m.[Graduated Tier 3 Discount Rate] <= m.[Graduated Tier 4 Discount Rate]) THEN 'Graduated Tier 3 Discount Rate'
                            WHEN (m.[Graduated Tier 4 Discount Rate] <= m.[Graduated Tier 5 Discount Rate]) THEN 'Graduated Tier 4 Discount Rate'
                            WHEN (m.[Graduated Tier 5 Discount Rate] <= m.[Graduated Tier 6 Discount Rate]) THEN 'Graduated Tier 5 Discount Rate'
							END,
	[Flagged Column Value] = CASE 
                            WHEN ( m.[Direct Rate] <= m.[Graduated Tier 1 Discount Rate] )THEN CAST(m.[Direct Rate] as nvarchar) 
                            WHEN (m.[Graduated Tier 1 Discount Rate] <= m.[Graduated Tier 2 Discount Rate]) THEN CAST(m.[Graduated Tier 1 Discount Rate] as nvarchar)
                            WHEN (m.[Graduated Tier 2 Discount Rate] <= m.[Graduated Tier 3 Discount Rate]) THEN CAST(m.[Graduated Tier 2 Discount Rate] as nvarchar)
                            WHEN (m.[Graduated Tier 3 Discount Rate] <= m.[Graduated Tier 4 Discount Rate]) THEN CAST(m.[Graduated Tier 3 Discount Rate] as nvarchar)
                            WHEN (m.[Graduated Tier 4 Discount Rate] <= m.[Graduated Tier 5 Discount Rate]) THEN CAST(m.[Graduated Tier 4 Discount Rate] as nvarchar)
                            WHEN (m.[Graduated Tier 5 Discount Rate] <= m.[Graduated Tier 6 Discount Rate]) THEN CAST(m.[Graduated Tier 5 Discount Rate] as nvarchar)
							END,
	[Remarks] = CASE 
                            WHEN ( m.[Direct Rate] <= m.[Graduated Tier 1 Discount Rate] )
                            THEN 'Meter Direct Rate: '+CAST(m.[Direct Rate] as nvarchar)+'is lower than Meter Graduated Tier 1 Discount Rate of ('+ CAST(m.[Graduated Tier 1 Discount Rate] as nvarchar)+')'
                            WHEN (m.[Graduated Tier 1 Discount Rate] <= m.[Graduated Tier 2 Discount Rate]) 
                            THEN 'Meter Graduated Tier 1 Discount Rate:('+CAST(m.[Graduated Tier 1 Discount Rate] as nvarchar)+') is lower than Meter Graduated Tier 2 Discount Rate of ('+ CAST(m.[Graduated Tier 2 Discount Rate] as nvarchar)+')'

                            WHEN (m.[Graduated Tier 2 Discount Rate] <= m.[Graduated Tier 3 Discount Rate]) 
                            THEN 'Meter Graduated Tier 2 Discount Rate:('+CAST(m.[Graduated Tier 2 Discount Rate] as nvarchar)+') is lower than Meter Graduated Tier 3 Discount Rate of ('+ CAST(m.[Graduated Tier 3 Discount Rate] as nvarchar)+')'
                            
                            WHEN (m.[Graduated Tier 3 Discount Rate] <= m.[Graduated Tier 4 Discount Rate]) 
                            THEN 'Meter Graduated Tier 3 Discount Rate:('+CAST(m.[Graduated Tier 3 Discount Rate] as nvarchar)+') is lower than Meter Graduated Tier 4 Discount Rate of ('+ CAST(m.[Graduated Tier 4 Discount Rate] as nvarchar)+')'
                            
                            WHEN (m.[Graduated Tier 4 Discount Rate] <= m.[Graduated Tier 5 Discount Rate]) 
                            THEN 'Meter Graduated Tier 4 Discount Rate:('+CAST(m.[Graduated Tier 4 Discount Rate] as nvarchar)+') is lower than Meter Graduated Tier 5 Discount Rate of ('+ CAST(m.[Graduated Tier 5 Discount Rate] as nvarchar)+')'
                            
                            WHEN (m.[Graduated Tier 5 Discount Rate] <= m.[Graduated Tier 6 Discount Rate]) 
                            THEN 'Meter Graduated Tier 5 Discount Rate:('+CAST(m.[Graduated Tier 5 Discount Rate] as nvarchar)+') is lower than Meter Graduated Tier 6 Discount Rate of ('+ CAST(m.[Graduated Tier 6 Discount Rate] as nvarchar)+')'
							END,
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	
FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKU] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]

		where
		 e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
         and  (
            (m.[Direct Rate] <= m.[Graduated Tier 1 Discount Rate])
            OR
            (m.[Graduated Tier 1 Discount Rate] <= m.[Graduated Tier 2 Discount Rate])
            OR
            (m.[Graduated Tier 2 Discount Rate] <= m.[Graduated Tier 3 Discount Rate])
            OR
            (m.[Graduated Tier 3 Discount Rate] <= m.[Graduated Tier 4 Discount Rate])
            OR
            (m.[Graduated Tier 4 Discount Rate] <= m.[Graduated Tier 5 Discount Rate])
            OR
            (m.[Graduated Tier 5 Discount Rate] <= m.[Graduated Tier 6 Discount Rate])

            )
	RETURN 
END
GO
