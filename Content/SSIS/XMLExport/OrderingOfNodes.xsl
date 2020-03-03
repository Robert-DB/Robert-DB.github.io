<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:n="http://ns.medbiq.org/name/v2/" exclude-result-prefixes="n"
 version="1.0">
 
  <xsl:output omit-xml-declaration="yes" indent="yes" />
 
<xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" />
      </xsl:copy>
   </xsl:template>
<xsl:template match="Member[@restrictions='Confidential']">
      <xsl:copy>
	    <xsl:apply-templates select="@*|UniqueID">
         <xsl:sort select="node()|@*"/>
		 </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>

   
   <xsl:variable name="vOrdered" select="'|UniqueId|Name|Address|EducationInfo|CertificationInfo|LicenseInfo|DisciplinaryInfo|ClinicalStatus|OccupationInfo|PersonalInfo|MembershipInfo|ModifiedDate|ExtensibleInfo|a|b|c|d|'" />
   <xsl:template match="Member">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrdered, concat('|',name(),'|'))" />
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   


   
   <xsl:variable name="vOrderedName" select="'|n:GivenName|n:GivenName2|n:FamilyName|n:GenerationIdentifier|n:Degree|n:Alias|'" />
   <xsl:template match="Name">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrderedName, concat('|',name(),'|'))" />     
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>


  
   <xsl:variable name="vOrderedAddress" select="'|a:ID|a:Organization|a:StreetAddressLine|a:StreetAddressLine2|a:StreetAddressLine3|a:City|a:StateOrProvince|a:PostalCode|a:Region|a:District|a:Country|a:CountryType|'" />
   <xsl:template match="Address">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrderedAddress, concat('|',name(),'|'))" />
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   <xsl:variable name="vOrderedEducationInfo" select="'|Degree|EducationalCertificate|InstitutionInfo|Accreditation|ProgramName|ProgramID|DisciplineOrSpecialty|Distinction|EducationStatus|ClassLevel|StartDate|EndDate|CompletionDate|CompletionDocumentIssuedDate|'" />
   <xsl:template match="EducationInfo">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrderedEducationInfo, concat('|',name(),'|'))" />
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   <xsl:variable name="vOrderedInstitutionInfo" select="'|InstitutionName|InstitutionID|Address|'" />
   <xsl:template match="InstitutionInfo">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrderedInstitutionInfo, concat('|',name(),'|'))" />
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   <xsl:variable name="vOrderedCertificationInfo" select="'|RecognitionOrganization|CertificationBoard|CertificationStatus|CertificationStatusValidUntilDate|CertificationMaintenance|CertificationMaintenanceRequired|CertificateInfo|'" />
   <xsl:template match="CertificationInfo">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrderedCertificationInfo, concat('|',name(),'|'))" />
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   <xsl:variable name="vOrderedCertificateInfo" select="'|CertificateName|CertificateType|CertificateFocus|CertificateStatus|CertificateMaintenance|CertificateMaintenanceRequired|CertificateIssuance|Recognition|CertificateNotices|'" />
   <xsl:template match="CertificateInfo">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrderedCertificateInfo, concat('|',name(),'|'))" />
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   <xsl:variable name="vOrderedCertificateIssuance" select="'|CertificateIssuanceID|CertificateIssuanceFocus|CertificateIssuanceDuration|CertificateIssuanceOccurrence|CertificateIssueDate|CertificateExpireDate|CertificateIssuanceScheduledUpdate|CertificateIssuanceStatus|CertificateIssuanceNotices|'" />
   <xsl:template match="CertificateIssuance">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrderedCertificateIssuance, concat('|',name(),'|'))" />
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   <xsl:variable name="vOrderedLicense" select="'|LicensureEntity|LicenseNumberAvailability|LicenseNumber|LicenseCategory|Profession|Jurisdiction|InitialLicensureDate|LicenseStatus|LicenseExpirationDate|LicenseNotices|'" />
   <xsl:template match="License">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrderedLicense, concat('|',name(),'|'))" />
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   <xsl:variable name="vOrderedLicensureEntity" select="'|LicensureEntityName|ContactInformation|'" />
   <xsl:template match="LicensureEntity">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrderedLicensureEntity, concat('|',name(),'|'))" />
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   <xsl:variable name="vOrderedPersonalInfo" select="'|PhysicalStatus|BirthDate|DeceasedDate|Language|Citizenship|CountryOfResidence|CountryOfBirth|Gender|Race|Ethnicity|ContactNumber|EmailAddress|URL|NationalID|FamilyMember|PreferredMethodOfContact|'" />
   <xsl:template match="PersonalInfo">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrderedPersonalInfo, concat('|',name(),'|'))" />
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   <xsl:variable name="vOrderedContactNumber" select="'|CountryCode|TelephoneNumber|Extension|Description|'" />
   <xsl:template match="ContactNumber">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*">
            <xsl:sort select="substring-before($vOrderedContactNumber, concat('|',name(),'|'))" />
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   


</xsl:stylesheet>

