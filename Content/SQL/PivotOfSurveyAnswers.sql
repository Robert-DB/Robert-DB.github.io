--THIS CODE IS PART OF A LARGE SCALE DATA MIGRATION FROM OLD, UNDOCUMENTED ORACLE DATA, TO SQL SERVER.
--ONCE I FIGURED OUT WHAT THIS DATA WAS, I WROTE THIS PART IN ORDER TO MIGRATE SURVEY-TYPE ANSWERS TO SPECIFIC QUESTIONS
--WE NEEDED MOVED AND STRUCTURED TO FIT THE NEW SYSTEM DESIGN.  
--THIS IS A TINY PART OF THE MIGRATION CODE.

INSERT INTO t9attestation.dbo.attestor (
	[attestationinstanceid]
	,[isprimary]
	,[firstname]
	,[lastname]
	,[title]
	,[email]
	,[phone]
	,[fax]
	,[numberofactivities]
	,[hospitalname]
	,[hospitalcountry]
	,[hospitaladdressline1]
	,[hospitalcity]
	,[hospitalstateprovince]
	,[hospitalpostalcode]
	,[createdby]
	,Created
	)
SELECT attestationinstanceid
	,1 AS 'IsPrimary'
	,[51] AS 'FirstName'
	,[52] AS 'LastName'
	,Isnull([50], '') AS 'Title'
	,Isnull([54], '') AS 'Email'
	,Isnull([55], '') AS 'Phone'
	,[56] AS 'Fax'
	,Isnull([44], 0) AS 'NumberOfActivities'
	,Isnull([43], '') AS 'HospitalName'
	,Isnull([49], '') AS 'HospitalCountry'
	,Isnull([45], '') AS 'HospitalAddressLine1'
	,Isnull([46], '') AS 'HospitalCity'
	,Isnull([47], '') AS 'HospitalStateProvince'
	,Isnull([48], '') AS 'HospitalPostalCode'
	,'ACHD_MIGRATION'
	,@CurrentDateTime
FROM (
	SELECT FormLookup.attestationinstanceid
		,s.answer_id
		,s.response_value
		,s.response_id
		,s.dataset_id
	FROM #rf_temp_question_source s
	INNER JOIN @ID_LookupFormID FormLookup ON s.response_id = FormLookup.response_id
	WHERE s.question_id IN (
			105
			,370
			)
	) AS AttestorDriver
PIVOT(Max(response_value) FOR answer_id IN (
			[43]
			,[44]
			,[57]
			,[51]
			,[52]
			,[50]
			,[54]
			,[55]
			,[56]
			,[49]
			,[45]
			,[46]
			,[47]
			,[48]
			,[98]
			)) AS attestorpivotoutput
WHERE [52] IS NOT NULL
ORDER BY response_id