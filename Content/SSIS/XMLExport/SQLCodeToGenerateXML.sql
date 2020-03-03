	SET ANSI_NULLS ON
	GO

	SET QUOTED_IDENTIFIER ON
	GO


	CREATE PROCEDURE [rpt].[Get_ExportXMLwithEU]
	AS
	BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	 IF OBJECT_ID('tempdb..#RangeList') IS NOT NULL
	BEGIN
	  DROP TABLE #RangeList
	END



	SELECT  u.MemberId ,ISNULL(cn.DataPrivacyEnforced,0) DataPrivacyEnforced
	INTO #RangeList
	FROM IdentityData.UserProfile u
	INNER JOIN Certification.Credential ct ON u.MemberId = ct.MemberId
	INNER JOIN  Certification.Certification c ON c.CertificationId = ct.CertificationId
	INNER JOIN Certification.Issuance i ON ct.CredentialId = i.CredentialId 
	INNER JOIN Certification.Source s ON i.SourceId = s.SourceId
	LEFT JOIN IdentityData.addresses a ON u.profilekey = a.profile_key
	AND a.IsPrimary=1
	LEFT join IdentityData.country cn ON a.countryid = cn.code
	INNER JOIN IdentityData.UserAccounts ua ON u.MemberID=ua.ID
	WHERE (s.SourceId = 1 OR (s.SourceId = 2 and c.Code in ('ALLG','CLI','DLI')))
	--AND ISNULL(cn.DataPrivacyEnforced,0)=1  ---XXXXXXXXX Comment THIS OUT
	--AND ua.IsRetired = 0
	AND u.ProfileKey NOT IN
	(Select ParentKey
	From IdentityData.UserClaims
	Where [Type] = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'
	and Value = 'Demo-Account')

	AND Abimid IS NOT NULL 
	and u.Abimid <> 188481   --  re:  2.23
	--and ct.GracePeriodEndDate is not null
	--and CAST(u.Abimid as INT) >= 166000
	 --  349335  mult lic  337008 mult lic
	--AND u.memberId IN ('28C69264-54B8-405C-B5E3-3EA492D4475E', '1B1D5028-1915-49BA-9C8C-099E2EB3558B')
	--AND 

	--AND (Abimid BETWEEN 300000 AND 300100 OR 
	--  AbimId IN (
	-- 208083,
	--208083,
	--208083,
	--208083,
	--305625,
	--324321,
	--324321,
	--135760,
	--135760,
	--217251,
	--217251,
	--216367,
	--76246,
	--343933,
	--343919,
	--343943,
	--343927,
	--343917,
	--343913,
	--343910,
	--343904))
	-- --343934
	---- ,
	--343923,--,
	--343959--, -----------
	----343933
	----343919,
	----343943,
	----343927,
	----343917,
	----343913,
	----343910
	----343904,
	----343891,
	----343903,
	----343905,
	----343916
	--)

	--select COUNT(Distinct memberId) From #RangeList

	CREATE INDEX IDX_RangeList ON #RangeList (
	  MemberId

	  )
	--select * from #RangeList

	IF OBJECT_ID('tempdb..#CertificationMaintenance') IS NOT NULL
	BEGIN
	  DROP TABLE #CertificationMaintenance
	END



	SELECT ROW_NUMBER() OVER (
		PARTITION BY c.code
		,u.MemberId ORDER BY i.IssuanceDate DESC
		) AS IssuanceNum
	  ,c.Code
	  ,u.MemberId
	  ,i.MaintenanceStatus
	  ,i.IssuanceDate
	  ,i.Created
	  ,i.Modified
	INTO #CertificationMaintenance
	FROM Certification.Certification c
	INNER JOIN Certification.Credential ct ON c.CertificationId = ct.CertificationId
	LEFT JOIN Certification.Issuance i ON ct.CredentialId = i.CredentialId
	INNER JOIN IdentityData.UserProfile u ON u.MemberId = ct.MemberId
	LEFT JOIN Certification.Source s ON i.SourceId = s.SourceId
	WHERE (s.SourceId = 1 OR (s.SourceId = 2 and c.Code in ('ALLG','CLI','DLI'))) --'ABIM'
	  AND u.memberId IN (SELECT memberId FROM #RangeList)

	CREATE INDEX IDX_CertificationMaintenance ON #CertificationMaintenance (
	  MemberId
	  ,IssuanceDate
	  ,MaintenanceStatus
	  )

	/**
	IF OBJECT_ID('tempdb..#GivenName') IS NOT NULL
	BEGIN
	  DROP TABLE #GivenName
	END

	select [Key],Name,case Names 
			  when 'FirstName' then 'a'
			  when  'MiddleName' then 'b'
			  end as 'Ordering'
	INTO #GivenName
	FROM 
	(SELECT [Key], FirstName,MiddleName FROM identitydata.useraccounts WITH (NOLOCK) ) as u
	 UNPIVOT 
	  (
		Name FOR Names IN (FirstName,MiddleName)
	  ) AS p




	CREATE INDEX IDX_GivenName ON #GivenName(
	[Key]
	  ) INCLUDE (Name)
	**/

	--select * from [dbo].[AbmsXml] 
	 --

	TRUNCATE TABLE [dbo].[AbmsXml]
	Insert into  [dbo].[AbmsXml](XMLText) VALUES('<root></root>')
	UPDATE [dbo].[AbmsXml]
	SET XMLText = (SELECT * FROM
	(




	SELECT 1 AS Tag
	  ,NULL AS Parent
	  ,NULL AS [Members!1]
	  ,'http://ns.medbiq.org/member/v2/' AS [Members!1!xmlns:med]
	  ,'http://ns.medbiq.org/address/v2/' AS [Members!1!xmlns:a]
	  ,'http://ns.medbiq.org/name/v2/' AS [Members!1!xmlns:n]
	  ,NULL AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]


	UNION ALL

	SELECT DISTINCT 2 AS Tag
	  ,1 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  u.id AS [Member!2!MemberGuid!hide]
	  ,CASE   --XXXXX Add this
	  WHEN DataPrivacyEnforced = 1 THEN 'Confidential'
	  ELSE 'Unrestricted'
	  END AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	FROM identitydata.useraccounts u WITH (NOLOCK)
	INNER JOIN  #RangeList r
	ON u.id = r.MemberID   --XXXXXXXX ChangeThis

	--IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 3 AS Tag
	  ,2 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  u.id AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,CASE i.type
		WHEN 'http://schemas.abim.org/2016/identifier/abim'
		  THEN 'idd:ABIM.org:BoardUniqueID'
		WHEN 'http://schemas.abim.org/2016/identifier/abms'
		  THEN 'idd:ABMS.org:ABMSUniqueID'
		   WHEN 'http://schemas.abim.org/2016/identifier/npi'
		  THEN 'idd:cms.gov:npi'
		ELSE NULL
		END AS [UniqueID!3!domain]
	  ,CASE i.type
		WHEN 'http://schemas.abim.org/2016/identifier/abim'
		THEN right('0000000000' + rtrim(i.value), 6)
		WHEN 'http://schemas.abim.org/2016/identifier/npi'
		THEN right('0000000000' + rtrim(i.value), 10)
	 ELSE i.value END AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--select u.ID,i.Type,i.Value as 'UniqueID', 
	--u.LastName as 'FamilyName', u.FirstName as  'GivenName' 
	FROM identitydata.useraccounts u WITH (NOLOCK)
	LEFT JOIN identitydata.userclaims i ON i.parentkey = u.[key]
	  AND i.type IN ('http://schemas.abim.org/2016/identifier/abim', 'http://schemas.abim.org/2016/identifier/abms','http://schemas.abim.org/2016/identifier/npi')
	WHERE u.id IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 4 AS Tag
	  ,2 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  u.id AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,FORMAT(ISNULL(u.NameModifiedDate, u.Created), 'yyyy-MM-dd') AS [Name!4!validityDate],u.ID AS [Name!4!MemberGuid!Hide]
	  ,u.FirstName AS [Name!4!n:GivenName!Element],u.MiddleName AS [Name!4!n:GivenName2!Element]
	  ,u.lastname AS [Name!4!n:FamilyName!Element],u.Suffix AS [Name!4!n:GenerationIdentifier!Element]
	  ,uams.Degree AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--select u.ID,i.Type,i.Value as 'UniqueID', 
	--u.LastName as 'FamilyName', u.FirstName as  'GivenName' 
	FROM identitydata.useraccounts u WITH (NOLOCK)
	OUTER APPLY (SELECT TOP 1 ums.Degree,ums.DegreeEarnedDate FROM identitydata.useraccountsMedicalSchool ums WHERE ums.UserAccountsId = u.[Key]
	ORDER BY ums.DegreeEarnedDate DESC) uams
	--LEFT JOIN identitydata.UserAccountsNameAlias na ON u.[Key] = na.UserAccountsId
	WHERE u.id IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 5 AS Tag
	  ,2 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,CASE 
		WHEN a.isprimary = 1
		  THEN 'primary'
		ELSE NULL
		END AS [Address!5!source]
	  ,Format(Isnull(a.modified,a.created ), 'yyyy-MM-dd') AS [Address!5!validityDate]
	  ,CASE a.addresstype
		WHEN 1
		  THEN 'Residential'
		WHEN 0
		  THEN 'Business'
		ELSE NULL
		END AS [Address!5!addressCategory]
	  ,CASE 
	  WHEN a.addressesGuid IS NULL THEN NULL
	  ELSE 'Unrestricted' 
	  END AS [Address!5!restrictions]
	  ,a.addressesGuid AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,a.city AS [Address!5!a:City!Element]
	  ,r.code AS [Address!5!a:StateOrProvince!Element]
	  ,a.postalcode AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--Select a.ID, a.AddressType,a.StreetAddress1,a.City,a.IsPrimary, 
	--a.RegionId,r.Code RegionCode,r.Name RegionName,a.PostalCode,a.CountryId,c.Name CountryName, 
	--ISNULL(a.Created,a.Modified) ValidityDate 
	FROM IdentityData.UserProfile up
	LEFT JOIN IdentityData.addresses a ON up.profilekey = a.profile_key
	LEFT join IdentityData.country c ON a.countryid = c.code
	LEFT join IdentityData.Region r ON a.regionid = r.regionid
	WHERE up.memberid IN (SELECT memberId FROM #RangeList)


	UNION ALL

	SELECT DISTINCT 6 AS Tag
	  ,5 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,a.addressesGuid AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,c.NAME AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--Select a.ID, a.AddressType,a.StreetAddress1,a.City,a.IsPrimary, 
	--a.RegionId,r.Code RegionCode,r.Name RegionName,a.PostalCode,a.CountryId,c.Name CountryName, 
	--ISNULL(a.Created,a.Modified) ValidityDate 
	FROM IdentityData.UserProfile up
	LEFT JOIN IdentityData.addresses a ON up.profilekey=a.profile_key 
	LEFT join IdentityData.country c ON a.countryid = c.code
	LEFT join IdentityData.Region r ON a.regionid = r.regionid
	WHERE up.memberid IN (SELECT memberId FROM #RangeList)
	--	ORDER BY [Member!2!MemberGuid!hide]
	--  ,[Address!5!a:ID!ELEMENT],[EducationInfo!7!compositeid!hide],[CertificationInfo!8!CredentialId!hide]
	-- ,[CertificateInfo!9!CredentialId!hide] ,[CertificateIssuance!10!CertificateIssuanceID!Element]
	--FOR XML explicit

	UNION ALL

	SELECT DISTINCT 7 AS Tag
	  ,2 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,FORMAT(ISNULL(uams.Modified,uams.Created), 'yyyy-MM-dd') AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!] --XXXXXXneed date
	  ,uams.MedicalSchoolId AS [EducationInfo!7!compositeid!hide]
	  ,uams.Degree AS [EducationInfo!7!Degree!ELEMENT]
	  ,FORMAT(uams.DegreeEarnedDate, 'yyyy-MM-dd') AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT  uams.*,'xxx',ms.*--,ISNULL(uams.Created,uams.Modified) ValidityDate
	FROM IdentityData.UserProfile up
	LEFT JOIN identitydata.[UserAccountsMedicalSchool] uams ON up.ProfileKey=uams.UserAccountsId
	LEFT JOIN IdentityData.MedicalSchool ms ON uams.MedicalSchoolId = ms.MedicalSchoolId
	WHERE uams.MedicalSchoolId IS NOT NULL
	AND up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 8 AS Tag
	  ,2 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  u.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,'ABMS' AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,CASE s.Name
		WHEN 'American Board of Internal Medicine'
		  THEN 'ABIM'
		ELSE 'ABIM'
		END AS [CertificationInfo!8!CertificationBoard!Element]
	  ,u.MemberID AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--		select u.AbimId,ct.CredentialId, ct.SelectedToMaintain,c.Name as 'CertificateName', 'XXXX' as 'CertificateType',
	--ISNULL(i.Created,i.Modified) as  'ValidityDate',i.IssuanceId,i.Duration,i.Occurrence,i.IssuanceDate,
	--i.ExpirationDate as 'ExpireDzate',i.IssuanceStatus,
	--s.Name 'CertificationBoard',
	-- 'ABMS' as 'RecognitionOrganization',
	--ct.IsActive,  
	--ct.SelectedToMaintain as 'CertificationMaintenance',i.ScheduledUpdate
	FROM IdentityData.UserProfile u
	INNER JOIN Certification.Credential ct ON u.MemberId = ct.MemberId
	INNER JOIN  Certification.Certification c ON c.CertificationId = ct.CertificationId
	INNER JOIN Certification.Issuance i ON ct.CredentialId = i.CredentialId 
	INNER JOIN Certification.Source s ON i.SourceId = s.SourceId
	WHERE (s.SourceId = 1 OR (s.SourceId = 2 and c.Code in ('ALLG','CLI','DLI')))
	  AND u.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 9 AS Tag
	  ,8 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  u.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,u.MemberID AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  , CASE WHEN c.Type IN ('FocusPractice') THEN 'IM' ELSE c.Code END AS [CertificateInfo!9!CertificateName!Element]
	  ,CASE 
		WHEN c.Type IN ('Primary','FocusPractice')
		  THEN 'General Certificate'
		ELSE 'Subcertificate'
		END AS [CertificateInfo!9!CertificateType!Element] --xxxxx
	  ,ct.CredentialId AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--		select u.AbimId,ct.CredentialId, ct.SelectedToMaintain,c.Name as 'CertificateName', 'XXXX' as 'CertificateType',
	--ISNULL(i.Created,i.Modified) as  'ValidityDate',i.IssuanceId,i.Duration,i.Occurrence,i.IssuanceDate,
	--i.ExpirationDate as 'ExpireDzate',i.IssuanceStatus,
	--s.Name 'CertificationBoard',
	-- 'ABMS' as 'RecognitionOrganization',
	--ct.IsActive,  
	--ct.SelectedToMaintain as 'CertificationMaintenance',i.ScheduledUpdate
	FROM IdentityData.UserProfile u
	INNER JOIN Certification.Credential ct ON u.MemberId = ct.MemberId
	INNER JOIN  Certification.Certification c ON c.CertificationId = ct.CertificationId
	INNER JOIN Certification.Issuance i ON ct.CredentialId = i.CredentialId 
	INNER JOIN Certification.Source s ON i.SourceId = s.SourceId
	WHERE (s.SourceId = 1 OR (s.SourceId = 2 and c.Code in ('ALLG','CLI','DLI')))
	  AND u.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 10 AS Tag
	  ,9 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  u.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,u.MemberID AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element] --xxxxx
	  ,ct.CredentialId AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,FORMAT(ISNULL(i.Modified,i.Created ), 'yyyy-MM-dd') AS [CertificateIssuance!10!validityDate]
	  ,i.IssuanceGuid AS [CertificateIssuance!10!CertificateIssuanceID!Element],
	  CASE
	  WHEN c.Type IN ('FocusPractice') THEN c.Code  ELSE NULL END AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,CASE i.Duration
	  WHEN 'Timelimited' THEN 'Time-limited' ELSE i.Duration END AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,i.Occurrence AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,FORMAT(i.IssuanceDate, 'yyyy-MM-dd') AS [CertificateIssuance!10!CertificateIssueDate!Element]

	  ,
	 NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,i.IssuanceStatus AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--		select u.AbimId,ct.CredentialId, ct.SelectedToMaintain,c.Name as 'CertificateName', 'XXXX' as 'CertificateType',
	--ISNULL(i.Created,i.Modified) as  'ValidityDate',i.IssuanceId,i.Duration,i.Occurrence,i.IssuanceDate,
	--i.ExpirationDate as 'ExpireDzate',i.IssuanceStatus,
	--s.Name 'CertificationBoard',
	-- 'ABMS' as 'RecognitionOrganization',
	--ct.IsActive,  
	--ct.SelectedToMaintain as 'CertificationMaintenance',i.ScheduledUpdate
	FROM IdentityData.UserProfile u
	INNER JOIN Certification.Credential ct ON u.MemberId = ct.MemberId
	INNER JOIN  Certification.Certification c ON c.CertificationId = ct.CertificationId
	INNER JOIN Certification.Issuance i ON ct.CredentialId = i.CredentialId 
	INNER JOIN Certification.Source s ON i.SourceId = s.SourceId
	WHERE (s.SourceId = 1 OR (s.SourceId = 2 and c.Code in ('ALLG','CLI','DLI')))
	  AND u.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 11 AS Tag
	  ,2 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.MemberID AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,up.ProfileKey AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--select u.ID,i.Type,i.Value as 'UniqueID', 
	--u.LastName as 'FamilyName', u.FirstName as  'GivenName' 
	FROM IdentityData.UserProfile up
	LEFT JOIN IdentityData.Licenses l ON up.ProfileKey=l.MedicalLicense_profileKey
	LEFT join IdentityData.Region r ON l.RegionId = r.RegionId
	LEFT join IdentityData.country c ON l.CountryId=c.Code
	WHERE IsDeleted = 0  AND c.Code IS NOT NULL  AND l.Id IS NOT NULL
	  AND up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 12 AS Tag
	  ,11 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.MemberID AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,up.ProfileKey AS [LicenseInfo!11!memberId!Hide]
	  ,
	  CASE
	  WHEN l.id IS NULL THEN NULL
	  ELSE FORMAT(ISNULL(l.Modified,l.Created ), 'yyyy-MM-dd') 
	  END AS [License!12!validityDate]
	  ,l.id AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,CASE 
	  WHEN l.id IS NULL THEN NULL
		WHEN ISNULL(l.LicenseNumber, '') = ''
		  THEN 'Unknown'
		ELSE 'Available'
		END AS [License!12!LicenseNumberAvailability!Element]
	  ,l.LicenseNumber AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT l.*,r.Name,r.Code,
	--CASE 
	--WHEN ISNULL(l.LicenseNumber,'') = '' THEN 'Unknown'
	--ELSE 'Available' END as 'LicenseNumberAvailability'
	FROM IdentityData.UserProfile up
	LEFT JOIN IdentityData.Licenses l ON up.ProfileKey=l.MedicalLicense_profileKey
	LEFT join IdentityData.Region r ON l.RegionId = r.RegionId
	LEFT join IdentityData.country c ON l.CountryId=c.Code
	WHERE IsDeleted = 0  AND c.Code IS NOT NULL  AND l.Id IS NOT NULL
	  AND up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 13 AS Tag
	  ,2 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  a.ID AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,a.[Key] AS [PersonalInfo!13!ProfileKey!Hide]
	  ,FORMAT(ISNULL(a.NameModifiedDate,a.Created ), 'yyyy-MM-dd') AS [PersonalInfo!13!validityDate]
	  ,CASE a.IsDeceased
		WHEN 1
		  THEN 'Deceased'
		ELSE 'Living'
		END AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,a.Gender AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT CASE a.IsDeceased
	--WHEN 1 THEN 'Deceased'
	--ELSE 'Living' END as 'PhysicalStatus',FORMAT(ISNULL(a.Created,a.NameModifiedDate),'yyyy-MM-dd') as 'validityDate',FORMAT(a.BirthDate,'yyyy-MM-dd') as 'BirthDate',a.Gender,a.Email,i.Value as 'NationalId',
	--ph.Phone
	FROM identitydata.UserAccounts a
	LEFT JOIN identitydata.PhoneNumbers ph ON a.[key] = ph.Profile_Key
	  AND ph.IsPrimary = 1
	LEFT JOIN identitydata.UserClaims i ON i.ParentKey = a.[key]
	  AND i.Type IN ('http://schemas.abim.org/2016/identifier/partialtaxid','http://schemas.abim.org/2016/identifier/partialtaxidcananda')
	WHERE a.ID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 14 AS Tag
	  ,13 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  a.id AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,a.[Key] AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,CASE
	  WHEN a.BirthDate IS NULL THEN NULL ELSE 'Unrestricted' END AS [BirthDate!14!restrictions]
	  ,FORMAT(a.BirthDate, 'yyyy-MM-dd') AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT CASE a.IsDeceased
	--WHEN 1 THEN 'Deceased'
	--ELSE 'Living' END as 'PhysicalStatus',FORMAT(ISNULL(a.Created,a.NameModifiedDate),'yyyy-MM-dd') as 'validityDate',FORMAT(a.BirthDate,'yyyy-MM-dd') as 'BirthDate',a.Gender,a.Email,i.Value as 'NationalId',
	--ph.Phone
	FROM identitydata.UserAccounts a
	LEFT JOIN identitydata.PhoneNumbers ph ON a.[key] = ph.Profile_Key
	  AND ph.IsPrimary = 1
	LEFT JOIN identitydata.UserClaims i ON i.ParentKey = a.[key]
	  AND i.Type IN ('http://schemas.abim.org/2016/identifier/partialtaxid','http://schemas.abim.org/2016/identifier/partialtaxidcananda')
	WHERE a.ID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 15 AS Tag
	  ,13 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  a.id AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,a.[Key] AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,FORMAT(ISNULL(ph.Modified, ph.Created), 'yyyy-MM-dd') AS [ContactNumber!15!validityDate]
	  ,CASE ph.IsPrimary
		WHEN 1
		  THEN 'Primary'
		ELSE NULL
		END AS [ContactNumber!15!source]
	  ,CASE 
	  WHEN ph.Phone IS NULL THEN NULL ELSE 'Confidential' END AS [ContactNumber!15!restrictions]
	  ,ph.Phone AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,c.PhoneCode AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,CASE ph.PhoneType
		WHEN '0'
		  THEN 'Office'
		WHEN '1'
		  THEN 'Mobile'
		WHEN '2'
		  THEN 'Home'
		WHEN '3'
		  THEN 'Assistant'
		WHEN '4'
		  THEN 'Other'
		WHEN '5'
		  THEN 'Fax'
		ELSE NULL
		END [ContactNumber!15!Description!ELEMENT] --XXX Type???
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT CASE a.IsDeceased
	--WHEN 1 THEN 'Deceased'
	--ELSE 'Living' END as 'PhysicalStatus',FORMAT(ISNULL(a.Created,a.NameModifiedDate),'yyyy-MM-dd') as 'validityDate',FORMAT(a.BirthDate,'yyyy-MM-dd') as 'BirthDate',a.Gender,a.Email,i.Value as 'NationalId',
	--ph.Phone
	FROM identitydata.UserAccounts a
	LEFT JOIN identitydata.PhoneNumbers ph ON a.[key] = ph.Profile_Key
	LEFT join IdentityData.country c ON ph.CountryCode = c.Code
	LEFT JOIN identitydata.UserClaims i ON i.ParentKey = a.[key]
	  AND i.Type IN ('http://schemas.abim.org/2016/identifier/partialtaxid','http://schemas.abim.org/2016/identifier/partialtaxidcananda')
	WHERE a.ID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 16 AS Tag
	  ,13 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  a.id AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,a.[Key] AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT] --XXX Type???
	  ,i.Value AS [NationalID!16!]
	  ,CASE
	  WHEN i.Value IS NULL THEN NULL 
	  ELSE 'Tax number' END AS [NationalID!16!idType],
	  CASE  WHEN i.Value IS NULL THEN NULL 
	  WHEN i.Type = 'http://schemas.abim.org/2016/identifier/partialtaxid' THEN 'US'
	  WHEN i.Type = 'http://schemas.abim.org/2016/identifier/partialtaxidcananda' THEN 'CA'
	  ELSE NULL END AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT CASE a.IsDeceased
	--WHEN 1 THEN 'Deceased'
	--ELSE 'Living' END as 'PhysicalStatus',FORMAT(ISNULL(a.Created,a.NameModifiedDate),'yyyy-MM-dd') as 'validityDate',FORMAT(a.BirthDate,'yyyy-MM-dd') as 'BirthDate',a.Gender,a.Email,i.Value as 'NationalId',
	--ph.Phone
	FROM identitydata.UserAccounts a
	LEFT JOIN identitydata.PhoneNumbers ph ON a.[key] = ph.Profile_Key
	  AND ph.IsPrimary = 1
	LEFT JOIN identitydata.UserClaims i ON i.ParentKey = a.[key]
	  AND i.Type IN ('http://schemas.abim.org/2016/identifier/partialtaxid','http://schemas.abim.org/2016/identifier/partialtaxidcananda')
	WHERE a.ID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 17 AS Tag
	  ,5 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,a.addressesGuid AS [Address!5!a:ID!ELEMENT]
	  ,CASE 
	   WHEN a.StreetAddress1 IS NULL THEN NULL
	   WHEN RTRIM(a.StreetAddress1) = '' THEN NULL
	   ELSE a.StreetAddress1
	   END AS [a:StreetAddressLine!17!]
	  ,CASE 
	   WHEN a.StreetAddress1 IS NULL THEN NULL
	   WHEN RTRIM(a.StreetAddress1) = '' THEN NULL
		WHEN a.addresstype=0
		  THEN 'Unrestricted' --'Business'
		ELSE 'Confidential'
		END AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--Select a.ID, a.AddressType,a.StreetAddress1,a.City,a.IsPrimary, 
	--a.RegionId,r.Code RegionCode,r.Name RegionName,a.PostalCode,a.CountryId,c.Name CountryName, 
	--ISNULL(a.Created,a.Modified) ValidityDate 
	FROM IdentityData.UserProfile up 
	LEFT JOIN IdentityData.addresses a ON up.profilekey=a.profile_key
	LEFT join IdentityData.country c ON a.countryid = c.code
	LEFT join IdentityData.Region r ON a.regionid = r.regionid
	WHERE up.memberid IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 18 AS Tag
	  ,7 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,uams.MedicalSchoolId AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,uams.MedicalSchoolId AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,ms.SchoolName AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT  uams.*,'xxx',ms.*--,ISNULL(uams.Created,uams.Modified) ValidityDate
	FROM IdentityData.UserProfile up
	LEFT JOIN identitydata.[UserAccountsMedicalSchool] uams ON up.ProfileKey=uams.UserAccountsId
	LEFT JOIN IdentityData.MedicalSchool ms ON uams.MedicalSchoolId = ms.MedicalSchoolId
	WHERE uams.MedicalSchoolId IS NOT NULL
	AND up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 19 AS Tag
	  ,18 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,uams.MedicalSchoolId AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,uams.MedicalSchoolId AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,ms.AMACode AS [InstitutionID!19!] --NULL AS [InstitutionID!19!] -- --Parent 18
	  ,'idd:ABMS.org:AMACode' AS [InstitutionID!19!domain]--NULL AS [InstitutionID!19!domain] --
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT  uams.*,'xxx',ms.*--,ISNULL(uams.Created,uams.Modified) ValidityDate
	FROM IdentityData.UserProfile up
	LEFT JOIN identitydata.[UserAccountsMedicalSchool] uams ON up.ProfileKey=uams.UserAccountsId
	INNER JOIN IdentityData.MedicalSchool ms ON uams.MedicalSchoolId = ms.MedicalSchoolId
	WHERE up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 20 AS Tag
	  ,18 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,uams.MedicalSchoolId AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,uams.MedicalSchoolId AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,uams.MedicalSchoolId AS [Address!20!MedSchoolId!hide] --parent 18
	  ,ms.City AS [Address!20!a:City!Element]
	  ,r.Code AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT  uams.*,'xxx',ms.*--,ISNULL(uams.Created,uams.Modified) ValidityDate
	FROM IdentityData.UserProfile up
	LEFT JOIN identitydata.[UserAccountsMedicalSchool] uams ON up.ProfileKey=uams.UserAccountsId
	INNER JOIN IdentityData.MedicalSchool ms ON uams.MedicalSchoolId = ms.MedicalSchoolId
	LEFT join IdentityData.Region r ON ms.RegionId = r.RegionId
	WHERE up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 21 AS Tag
	  ,20 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,uams.MedicalSchoolId AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,uams.MedicalSchoolId AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,uams.MedicalSchoolId AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,c.Name AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT  uams.*,'xxx',ms.*--,ISNULL(uams.Created,uams.Modified) ValidityDate
	FROM IdentityData.UserProfile up
	LEFT JOIN identitydata.[UserAccountsMedicalSchool] uams ON up.ProfileKey=uams.UserAccountsId
	INNER JOIN IdentityData.MedicalSchool ms ON uams.MedicalSchoolId = ms.MedicalSchoolId
	INNER join IdentityData.country c ON ms.CountryId = c.Code
	WHERE up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 22 AS Tag
	  ,13 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  a.id AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,a.[Key] AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,
	  CASE
	   WHEN a.Email='abimid@abim.org' THEN NULL
	   WHEN a.Email=(CAST(up.Abimid AS VARCHAR(6)) + '@abim.org') THEN NULL
	  WHEN a.IsAccountVerified=0 THEN NULL
	  ELSE a.Email END AS [EmailAddress!22!]
	  ,CASE 
	  WHEN a.Email IS NULL THEN NULL ELSE 'Confidential' END AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	FROM IdentityData.UserAccounts a
	INNER JOIN IdentityData.UserProfile up
	ON a.[Key] = up.ProfileKey
	LEFT JOIN IdentityData.UserClaims i ON i.ParentKey = a.[key]
	  AND i.Type IN ('http://schemas.abim.org/2016/identifier/partialtaxid','http://schemas.abim.org/2016/identifier/partialtaxidcananda')
	WHERE a.ID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 23 AS Tag
	  ,12 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.MemberID AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,up.ProfileKey AS [LicenseInfo!11!memberId!Hide]
	  ,NULL AS [License!12!validityDate]
	  ,l.id AS [License!12!LicenseId!Hide]
	  ,ISNULL(r.Code,c.Code) AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT l.*,r.Name,r.Code,
	--CASE 
	--WHEN ISNULL(l.LicenseNumber,'') = '' THEN 'Unknown'
	--ELSE 'Available' END as 'LicenseNumberAvailability'
	FROM IdentityData.UserProfile up
	LEFT JOIN IdentityData.Licenses l ON up.ProfileKey=l.MedicalLicense_profileKey
	LEFT join IdentityData.Region r ON l.RegionId = r.RegionId
	LEFT join IdentityData.country c ON l.CountryId=c.Code
	WHERE IsDeleted = 0 AND c.Code IS NOT NULL  AND l.Id IS NOT NULL
	  AND up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 24 AS Tag
	  ,8 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  u.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,u.MemberID AS [CertificationInfo!8!CredentialId!hide]
	  ,CASE 
		WHEN MaintainedList.Created IS NULL
		  THEN 'Not Maintained'
		ELSE 'Maintained'
		END AS [CertificationMaintenance!24!]
	  ,FORMAT(CASE 
		  WHEN MaintainedList.Created IS NULL
			THEN ISNULL(NotMaintainedList.Modified, NotMaintainedList.Created)
		  ELSE ISNULL(MaintainedList.Modified, MaintainedList.Created)
		  END, 'yyyy-MM-dd') AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT u.MemberId ,
	--CASE 
	--WHEN MaintainedList.Created IS NULL
	--THEN 'Not maintained' 
	--ELSE 'Maintained' END as 'CertificationMaintenance',
	--CASE 
	--WHEN MaintainedList.Created IS NULL
	--THEN ISNULL(NotMaintainedList.Modified,NotMaintainedList.Created)
	--ELSE ISNULL(MaintainedList.Modified,MaintainedList.Created)
	--END as 'ValidityDate'
	FROM IdentityData.UserProfile u
	OUTER APPLY (
	  SELECT TOP 1 Modified
		,Created
	  FROM #CertificationMaintenance cte
	  WHERE  MaintenanceStatus = 'NotMaintained'
		AND cte.MemberId = u.MemberID
	  ORDER BY IssuanceDate DESC
	  ) NotMaintainedList
	OUTER APPLY (
	  SELECT TOP 1 Modified
		,Created
	  FROM #CertificationMaintenance cte
	  WHERE  MaintenanceStatus = 'Maintained'
		AND cte.MemberId = u.MemberID
	  ORDER BY IssuanceDate DESC
	  ) MaintainedList
	WHERE u.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 25 AS Tag
	  ,10 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  u.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,u.MemberID AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element] --xxxxx
	  ,ct.CredentialId AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,i.IssuanceGuid AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  , CASE
	  WHEN i.Duration = 'Continuous' AND i.IssuanceStatus = 'Active' THEN 
	CASE
	  WHEN MONTH(GETDATE()) < 3 THEN FORMAT(DATEFROMPARTS(YEAR(GETDATE()),4,1), 'yyyy-MM-dd')
		WHEN MONTH(GETDATE()) >= 3 THEN FORMAT(DATEFROMPARTS(YEAR(GETDATE())+1,4,1), 'yyyy-MM-dd')
	  END
	  WHEN i.Duration = 'Timelimited' AND i.IssuanceStatus  = 'Active' AND i.ExpirationDate < GETDATE() 
	  --AND GETDATE() >= ct.GracePeriodStartDate  --REMOVED 2-12-2019 Task 142578
	  THEN 
	CASE
	  WHEN MONTH(GETDATE()) < 3 THEN FORMAT(DATEFROMPARTS(YEAR(GETDATE()),4,1), 'yyyy-MM-dd')
		WHEN MONTH(GETDATE()) >= 3 THEN FORMAT(DATEFROMPARTS(YEAR(GETDATE())+1,4,1), 'yyyy-MM-dd')
	  END
	  ELSE NULL
	  END AS [CertificateIssuanceScheduledUpdate!25!] --i.ScheduledUpdate
	  ,CASE
	  WHEN i.Duration = 'Continuous' AND i.IssuanceStatus = 'Active' THEN 'DayMonthYear' 
		WHEN i.Duration = 'Timelimited' AND i.IssuanceStatus  = 'Active' AND i.ExpirationDate < GETDATE() AND GETDATE() >= ct.GracePeriodStartDate THEN 
	'DayMonthYear' ELSE NULL END AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--		select u.AbimId,ct.CredentialId, ct.SelectedToMaintain,c.Name as 'CertificateName', 'XXXX' as 'CertificateType',
	--ISNULL(i.Created,i.Modified) as  'ValidityDate',i.IssuanceId,i.Duration,i.Occurrence,i.IssuanceDate,
	--i.ExpirationDate as 'ExpireDzate',i.IssuanceStatus,
	--s.Name 'CertificationBoard',
	-- 'ABMS' as 'RecognitionOrganization',
	--ct.IsActive,  
	--ct.SelectedToMaintain as 'CertificationMaintenance',i.ScheduledUpdate
	FROM IdentityData.UserProfile u
	INNER JOIN Certification.Credential ct ON u.MemberId = ct.MemberId
	INNER JOIN  Certification.Certification c ON c.CertificationId = ct.CertificationId
	INNER JOIN Certification.Issuance i ON ct.CredentialId = i.CredentialId 
	INNER JOIN Certification.Source s ON i.SourceId = s.SourceId
	WHERE (s.SourceId = 1 OR (s.SourceId = 2 and c.Code in ('ALLG','CLI','DLI')))
	AND u.MemberID IN (SELECT memberId FROM #RangeList)


	UNION ALL

	SELECT DISTINCT 26 AS Tag
	  ,23 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  up.MemberID AS [Member!2!MemberGuid!hide]
	  ,'Unrestricted' AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,up.ProfileKey AS [LicenseInfo!11!memberId!Hide]
	  ,NULL AS [License!12!validityDate]
	  ,l.id AS [License!12!LicenseId!Hide]
	  ,ISNULL(r.Code,c.Code) AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,c.Code AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	FROM IdentityData.UserProfile up
	LEFT JOIN IdentityData.Licenses l ON up.ProfileKey=l.MedicalLicense_profileKey
	LEFT join IdentityData.Region r ON l.RegionId = r.RegionId
	LEFT join IdentityData.country c ON l.CountryId=c.Code
	WHERE IsDeleted = 0 AND c.Code IS NOT NULL  AND l.Id IS NOT NULL
	  AND up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 27 AS Tag
	  ,26 AS Parent
	   ,NULL AS [Members!1]
	  ,NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  up.MemberID AS [Member!2!MemberGuid!hide]
	  ,'Unrestricted' AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,up.ProfileKey AS [LicenseInfo!11!memberId!Hide]
	  ,NULL AS [License!12!validityDate]
	  ,l.id AS [License!12!LicenseId!Hide]
	  ,ISNULL(r.Code,c.Code) AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,c.Code AS [ContactInformation!26!LicenseId!hide]
	  ,c.Code AS [Address!27!LicenseId!hide] --parent 26
	  ,r.Code AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	FROM IdentityData.UserProfile up
	LEFT JOIN IdentityData.Licenses l ON up.ProfileKey=l.MedicalLicense_profileKey
	LEFT join IdentityData.Region r ON l.RegionId = r.RegionId
	LEFT join IdentityData.country c ON l.CountryId=c.Code
	WHERE IsDeleted = 0 AND c.Code IS NOT NULL  AND l.Id IS NOT NULL
	  AND up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 28 AS Tag
	  ,27 AS Parent
	   ,NULL AS [Members!1]
	  ,NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  NULL
	  ,-- namespace 
	  up.MemberID AS [Member!2!MemberGuid!hide]
	  ,'Unrestricted' AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,up.ProfileKey AS [LicenseInfo!11!memberId!Hide]
	  ,NULL AS [License!12!validityDate]
	  ,l.id AS [License!12!LicenseId!Hide]
	  ,ISNULL(r.Code,c.Code) AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,c.Code AS [ContactInformation!26!LicenseId!hide]
	  ,c.Code AS [Address!27!LicenseId!hide] --parent 26
	  ,r.Code AS [Address!27!a:StateOrProvince!Element]
	  ,c.Code AS [a:Country!28!CountryCode!hide] --parent 27
	  ,c.Name AS [a:Country!28!a:CountryName!Element]
	FROM IdentityData.UserProfile up
	LEFT JOIN IdentityData.Licenses l ON up.ProfileKey=l.MedicalLicense_profileKey
	LEFT join IdentityData.Region r ON l.RegionId = r.RegionId
	LEFT join IdentityData.country c ON l.CountryId=c.Code
	WHERE IsDeleted = 0 AND c.Code IS NOT NULL  AND l.Id IS NOT NULL
	  AND up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 29 AS Tag
	  ,23 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.MemberID AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,up.ProfileKey AS [LicenseInfo!11!memberId!Hide]
	  ,NULL AS [License!12!validityDate]
	  ,l.id AS [License!12!LicenseId!Hide]
	  ,ISNULL(r.Code,c.Code) AS [LicensureEntity!23!EntityID!hide]
	  ,CASE 
	  WHEN l.id IS NULL THEN NULL
	  WHEN r.Name IS NULL THEN c.Name + ' Board' ELSE r.Name + ' Board' END AS [LicensureEntityName!29!]
	  ,CASE 
	  WHEN l.id IS NULL THEN NULL
	  WHEN r.Name IS NULL THEN c.Code ELSE r.Code END AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--SELECT l.*,r.Name,r.Code,
	--CASE 
	--WHEN ISNULL(l.LicenseNumber,'') = '' THEN 'Unknown'
	--ELSE 'Available' END as 'LicenseNumberAvailability'
	FROM IdentityData.UserProfile up
	LEFT JOIN IdentityData.Licenses l ON up.ProfileKey=l.MedicalLicense_profileKey
	LEFT join IdentityData.Region r ON l.RegionId = r.RegionId
	LEFT join IdentityData.country c ON l.CountryId=c.Code
	WHERE IsDeleted = 0 AND c.Code IS NOT NULL  AND l.Id IS NOT NULL
	  AND up.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 30 AS Tag
	  ,4 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  u.id AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],u.ID AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  , FORMAT(ISNULL(na.Modified, na.Created)
		 , 'yyyy-MM-dd') AS [n:Alias!30!validityDate]
	  ,na.FirstName AS [n:Alias!30!n:GivenName!Element],na.MiddleName AS [n:Alias!30!n:GivenName2!Element]
	  ,na.LastName AS [n:Alias!30!n:FamilyName!Element],na.Suffix AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--select u.ID,i.Type,i.Value as 'UniqueID', 
	--u.LastName as 'FamilyName', u.FirstName as  'GivenName' 
	FROM identitydata.useraccounts u WITH (NOLOCK)
	--LEFT JOIN identitydata.useraccountsMedicalSchool uams ON u.[Key] = uams.UserAccountsId
	LEFT JOIN identitydata.UserAccountsNameAlias na ON u.[Key] = na.UserAccountsId
	WHERE u.id IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 31 AS Tag
	  ,10 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  u.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,NULL AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions],NULL AS [a:StreetAddressLine2!32!],NULL AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,NULL AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,NULL AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,u.MemberID AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element] --xxxxx
	  ,ct.CredentialId AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,i.IssuanceGuid AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy]
	  , CASE
	   WHEN i.ExpirationDate IS NOT NULL THEN 'DayMonthYear' ELSE NULL END AS [CertificateExpireDate!31!accuracy]
	  ,FORMAT(i.ExpirationDate,'yyyy-MM-dd') AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--		select u.AbimId,ct.CredentialId, ct.SelectedToMaintain,c.Name as 'CertificateName', 'XXXX' as 'CertificateType',
	--ISNULL(i.Created,i.Modified) as  'ValidityDate',i.IssuanceId,i.Duration,i.Occurrence,i.IssuanceDate,
	--i.ExpirationDate as 'ExpireDzate',i.IssuanceStatus,
	--s.Name 'CertificationBoard',
	-- 'ABMS' as 'RecognitionOrganization',
	--ct.IsActive,  
	--ct.SelectedToMaintain as 'CertificationMaintenance',i.ScheduledUpdate
	FROM IdentityData.UserProfile u
	INNER JOIN Certification.Credential ct ON u.MemberId = ct.MemberId
	INNER JOIN  Certification.Certification c ON c.CertificationId = ct.CertificationId
	INNER JOIN Certification.Issuance i ON ct.CredentialId = i.CredentialId 
	INNER JOIN Certification.Source s ON i.SourceId = s.SourceId
	WHERE (s.SourceId = 1 OR (s.SourceId = 2 and c.Code in ('ALLG','CLI','DLI')))
	AND u.MemberID IN (SELECT memberId FROM #RangeList)

	UNION ALL

	SELECT DISTINCT 32 AS Tag
	  ,5 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,a.addressesGuid AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions]
	  ,CASE 
	   WHEN a.StreetAddress2 IS NULL THEN NULL
	   WHEN RTRIM(a.StreetAddress2) = '' THEN NULL
	   ELSE a.StreetAddress2
	   END   AS [a:StreetAddressLine2!32!]
		,CASE 
	   WHEN a.StreetAddress2 IS NULL THEN NULL
	   WHEN RTRIM(a.StreetAddress2) = '' THEN NULL
		WHEN a.addresstype=0
		  THEN 'Unrestricted' --'Business'
		ELSE 'Confidential'
		END  AS [a:StreetAddressLine2!32!restrictions],NULL AS [a:StreetAddressLine3!33!],NULL AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,r.Code AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,c.Name AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--Select a.ID, a.AddressType,a.StreetAddress1,a.City,a.IsPrimary, 
	--a.RegionId,r.Code RegionCode,r.Name RegionName,a.PostalCode,a.CountryId,c.Name CountryName, 
	--ISNULL(a.Created,a.Modified) ValidityDate 
	FROM IdentityData.UserProfile up 
	LEFT JOIN IdentityData.addresses a ON up.profilekey=a.profile_key
	LEFT join IdentityData.country c ON a.countryid = c.code
	LEFT join IdentityData.Region r ON a.regionid = r.regionid
	WHERE up.memberid IN (SELECT memberId FROM #RangeList)



	UNION ALL

	SELECT DISTINCT 33 AS Tag
	  ,5 AS Parent
	  ,NULL AS [Members!1]
	  ,NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  NULL
	  ,--namespace 
	  up.memberid AS [Member!2!MemberGuid!hide]
	  ,NULL AS [Member!2!restrictions]
	  ,NULL AS [UniqueID!3!domain]
	  ,NULL AS [UniqueID!3!]
	  ,NULL AS [Name!4!validityDate],NULL AS [Name!4!MemberGuid!Hide]
	  ,NULL AS [Name!4!n:GivenName!Element],NULL AS [Name!4!n:GivenName2!Element]
	  ,NULL AS [Name!4!n:FamilyName!Element],NULL AS [Name!4!n:GenerationIdentifier!Element]
	  ,NULL AS [Name!4!n:Degree!Element]
	  ,NULL AS [n:Alias!30!validityDate]
	  ,NULL AS [n:Alias!30!n:GivenName!Element],NULL AS [n:Alias!30!n:GivenName2!Element]
	  ,NULL AS [n:Alias!30!n:FamilyName!Element],NULL AS [n:Alias!30!n:GenerationIdentifier!Element]
	  ,NULL AS [Address!5!source]
	  ,NULL AS [Address!5!validityDate]
	  ,NULL AS [Address!5!addressCategory]
	  ,NULL AS [Address!5!restrictions]
	  ,a.addressesGuid AS [Address!5!a:ID!ELEMENT]
	  ,NULL AS [a:StreetAddressLine!17!]
	  ,NULL AS [a:StreetAddressLine!17!restrictions]
	  ,NULL AS [a:StreetAddressLine2!32!]
		,NULL  AS [a:StreetAddressLine2!32!restrictions]
		,CASE 
	   WHEN a.StreetAddress3 IS NULL THEN NULL
	   WHEN RTRIM(a.StreetAddress3) = '' THEN NULL
	   ELSE a.StreetAddress3
	   END  AS [a:StreetAddressLine3!33!]
		,CASE 
	   WHEN a.StreetAddress3 IS NULL THEN NULL
	   WHEN RTRIM(a.StreetAddress3) = '' THEN NULL
		WHEN a.addresstype=0
		  THEN 'Unrestricted' --'Business'
		ELSE 'Confidential'
		END  AS [a:StreetAddressLine3!33!restrictions]
	  ,NULL AS [Address!5!a:City!Element]
	  ,r.Code AS [Address!5!a:StateOrProvince!Element]
	  ,NULL AS [Address!5!a:PostalCode!Element]
	  ,NULL AS [a:Country!6!]
	  ,c.Name AS [a:Country!6!a:CountryName!Element]
	  ,NULL AS [EducationInfo!7!validityDate]
	  ,NULL AS [EducationInfo!7!]
	  ,NULL AS [EducationInfo!7!compositeid!hide]
	  ,NULL AS [EducationInfo!7!Degree!ELEMENT]
	  ,NULL AS [EducationInfo!7!EndDate!ELEMENT]
	  ,NULL AS [CertificationInfo!8!RecognitionOrganization!Element]
	  ,NULL AS [CertificationInfo!8!CertificationBoard!Element]
	  ,NULL AS [CertificationInfo!8!CredentialId!hide]
	  ,NULL AS [CertificationMaintenance!24!]
	  ,NULL AS [CertificationMaintenance!24!validityDate]
	  ,NULL AS [CertificateInfo!9!CertificateName!Element]
	  ,NULL AS [CertificateInfo!9!CertificateType!Element]
	  ,NULL AS [CertificateInfo!9!CredentialId!hide]
	  ,NULL AS [CertificateIssuance!10!]
	  ,NULL AS [CertificateIssuance!10!validityDate]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceID!Element],NULL AS [CertificateIssuance!10!CertificateIssuanceFocus!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceDuration!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceOccurrence!Element]
	  ,NULL AS [CertificateIssuance!10!CertificateIssueDate!Element]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!]
	  ,NULL AS [CertificateIssuanceScheduledUpdate!25!accuracy],NULL AS [CertificateExpireDate!31!accuracy],NULL AS [CertificateExpireDate!31!]
	  ,NULL AS [CertificateIssuance!10!CertificateIssuanceStatus!Element]
	  ,NULL AS [LicenseInfo!11!memberId!hide]
	  ,NULL AS [License!12!validityDate]
	  ,NULL AS [License!12!LicenseId!Hide]
	  ,NULL AS [LicensureEntity!23!EntityID!hide]
	  ,NULL AS [LicensureEntityName!29!]
	  ,NULL AS [LicensureEntityName!29!abbreviation]
	  ,NULL AS [License!12!LicenseNumberAvailability!Element]
	  ,NULL AS [License!12!LicenseNumber!Element]
	  ,NULL AS [PersonalInfo!13!ProfileKey!Hide]
	  ,NULL AS [PersonalInfo!13!validityDate]
	  ,NULL AS [PersonalInfo!13!PhysicalStatus!ELEMENT]
	  ,NULL AS [PersonalInfo!13!Gender!ELEMENT]
	  ,NULL AS [EmailAddress!22!]
	  ,NULL AS [EmailAddress!22!restrictions]
	  ,NULL AS [BirthDate!14!restrictions]
	  ,NULL AS [BirthDate!14!]
	  ,NULL AS [ContactNumber!15!]
	  ,NULL AS [ContactNumber!15!validityDate]
	  ,NULL AS [ContactNumber!15!source]
	  ,NULL AS [ContactNumber!15!restrictions]
	  ,NULL AS [ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,NULL AS [ContactNumber!15!CountryCode!ELEMENT]
	  ,NULL AS [ContactNumber!15!Description!ELEMENT]
	  ,NULL AS [NationalID!16!]
	  ,NULL AS [NationalID!16!idType],NULL AS [NationalID!16!countryCode]
	  ,NULL AS [InstitutionInfo!18!] --Parent 7
	  ,NULL AS [InstitutionInfo!18!MedSchoolId!hide]
	  ,NULL AS [InstitutionInfo!18!InstitutionName!ELEMENT]
	  ,NULL AS [InstitutionID!19!] --Parent 18
	  ,NULL AS [InstitutionID!19!domain]
	  ,NULL AS [Address!20!MedSchoolId!hide] --parent 18
	  ,NULL AS [Address!20!a:City!Element]
	  ,NULL AS [Address!20!a:StateOrProvince!Element]
	  ,NULL AS [Address!20!a:PostalCode!Element]
	  ,NULL AS [a:Country!21!] --parent 20
	  ,NULL AS [a:Country!21!a:CountryName!Element]
	  ,NULL AS [ContactInformation!26!LicenseId!hide]
	  ,NULL AS [Address!27!LicenseId!hide] --parent 26
	  ,NULL AS [Address!27!a:StateOrProvince!Element]
	  ,NULL AS [a:Country!28!CountryCode!hide] --parent 27
	  ,NULL AS [a:Country!28!a:CountryName!Element]
	--Select a.ID, a.AddressType,a.StreetAddress1,a.City,a.IsPrimary, 
	--a.RegionId,r.Code RegionCode,r.Name RegionName,a.PostalCode,a.CountryId,c.Name CountryName, 
	--ISNULL(a.Created,a.Modified) ValidityDate 
	FROM IdentityData.UserProfile up 
	LEFT JOIN IdentityData.addresses a ON up.profilekey=a.profile_key
	LEFT join IdentityData.country c ON a.countryid = c.code
	LEFT join IdentityData.Region r ON a.regionid = r.regionid
	WHERE up.memberid IN (SELECT memberId FROM #RangeList)

	) Sub


	--	ORDER BY [Member!2!MemberGuid!hide]
	--  ,[Address!5!a:ID!ELEMENT],[EducationInfo!7!compositeid!hide],[CertificationInfo!8!CredentialId!hide]
	-- ,[CertificateInfo!9!CredentialId!hide] ,[CertificateIssuance!10!CertificateIssuanceID!Element]
	--FOR XML explicit
	ORDER BY [Member!2!MemberGuid!hide]
	  ,[LicenseInfo!11!memberId!hide]
  
 
	  ,[Name!4!MemberGuid!Hide]
 
	  ,[n:Alias!30!n:FamilyName!Element]
	  ,[License!12!LicenseId!Hide],[LicensureEntity!23!EntityID!hide],[LicensureEntityName!29!]
	  ,[ContactInformation!26!LicenseId!hide] 
	  ,[Address!27!LicenseId!hide]
	  ,[a:Country!28!CountryCode!hide],[a:Country!28!a:CountryName!Element]
	  ,[UniqueID!3!]
	  ,[Address!5!a:ID!ELEMENT]
	  ,[a:StreetAddressLine!17!]
		,[a:StreetAddressLine2!32!]
	  ,[a:StreetAddressLine3!33!]
	  ,[a:Country!6!a:CountryName!Element]
	  ,[CertificationInfo!8!CredentialId!hide]
	  ,[CertificateInfo!9!CredentialId!hide]
	  ,[CertificateIssuance!10!CertificateIssuanceID!Element]
	  ,[CertificateExpireDate!31!]
	  ,[CertificateIssuanceScheduledUpdate!25!]
	  ,[CertificationMaintenance!24!validityDate]
	  ,[PersonalInfo!13!ProfileKey!Hide]
	  ,[BirthDate!14!]
	  ,[ContactNumber!15!TelephoneNumber!ELEMENT]
	  ,[NationalID!16!]
	  ,[EmailAddress!22!restrictions]
	  ,[EducationInfo!7!compositeid!hide]
	  ,[InstitutionInfo!18!MedSchoolId!hide]
	  ,[InstitutionID!19!]
	  ,[Address!20!MedSchoolId!hide]
	  ,[a:Country!21!a:CountryName!Element] 


	--
	-- 
	--
	--
	--
	--  
	FOR XML explicit

	)

	--SELECT XMLText FROM dbo.AbmsXml
	--SELECT @XMLText

	END



	GO


