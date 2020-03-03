

/****** Object:  View [dbo].[ICardReAttestationDueDate]    Script Date: 2/24/2020 1:55:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ICardReAttestationDueDate]
AS
--RULE Programs 006.1
--The Icard Reattestation Due Date must be the ICard certificate expiration date when all of the following are true:
--        - The Certificate is a Time Limited Certificate (Program Rule: Time Limited Certificate)
--        - The certificate expires in 2018 or earlier
--        - A previous re-attestation does not exist for this Certificate since the start date of the Certificate
								
SELECT credIssue.memberid       memberGUID, 
       CAST(credIssue.expirationdate AS DATE) DueDate, 
       'ICARDAttestMOC'         AttestationType 
FROM   dbo.credential_issuance credIssue 
	          OUTER apply (SELECT i.memberguid, 
                           i.attestationinstancestatusdate, 
                           'ATTESTATION' TypeOfCredential 
                    FROM   attestationinstance i 
                    WHERE  i.attestationcode IN ( 'ICARDAttestMOC' ) 
                           AND i.attestationinstancestatuscode = 'APPROVED' 
                           AND i.memberguid = credIssue.memberid 
                           AND i.attestationinstancestatusdate >= 
                               credIssue.effectivedate 
                          ) att 
WHERE  credIssue.CertCode = 'ICARD'
       AND credIssue.duration = 'Timelimited' 
       AND credIssue.expirationdate < '1/1/2019' 
	   AND att.memberguid IS NULL 
UNION
--RULE Programs 006.1a
--The ICard Reattestation Due Date must be 12/31/<year of last re-attestation plus 5> when all of the following are true:
--        - The Certificate is a Time Limited Certificate (Program Rule: Time Limited Certificate)
--        - The certificate expires in 2018 or earlier
--        - A previous re-attestation does exist for this Certificate since the start date of the Certificate
SELECT credIssue.memberid       memberGUID, 
         Datefromparts(Datepart(year, att.attestationinstancestatusdate) + 5, 12, 31)  DueDate, 
       'ICARDAttestMOC'         AttestationType 
FROM   dbo.credential_issuance credIssue 
	          OUTER apply (SELECT i.memberguid, 
                           i.attestationinstancestatusdate, 
                           'ATTESTATION' TypeOfCredential 
                    FROM   attestationinstance i 
                    WHERE  i.attestationcode IN ( 'ICARDAttestMOC' ) 
                           AND i.attestationinstancestatuscode = 'APPROVED' 
                           AND i.memberguid = credIssue.memberid 
                           AND i.attestationinstancestatusdate >= 
                               credIssue.effectivedate 

                          ) att 
WHERE  credIssue.CertCode = 'ICARD'
       AND credIssue.duration = 'Timelimited' 
       AND credIssue.expirationdate < '1/1/2019' 
	   AND att.memberguid IS NOT NULL 
UNION
--RULE Programs 006.2 
--The ICard Reattestation Due Date must be 12/31/2018 when all of the following are true:
--        - The Certificate is a Time Limited Certificate (Program Rule: Time Limited Certificate)
--        - The Certificate expires in 2019 or later
--        - A previous re-attestation does not exist for this Certificate between the start and end date of the Certificate

SELECT credIssue.memberid             memberGUID, 
       Cast('12/31/2018' AS DATE) DueDate, 
       'ICARDAttestMOC'               AttestationType 
FROM   dbo.credential_issuance credIssue 
       OUTER apply (SELECT i.memberguid, 
                           i.attestationinstancestatusdate, 
                           'ATTESTATION' TypeOfCredential 
                    FROM   attestationinstance i 
                    WHERE  i.attestationcode IN ( 'ICARDAttestMOC' ) 
                           AND i.attestationinstancestatuscode = 'APPROVED' 
                           AND i.memberguid = credIssue.memberid 
                           AND i.attestationinstancestatusdate >= 
                               credIssue.effectivedate 
                           AND i.attestationinstancestatusdate < Dateadd(d, 1, 
                               credIssue.expirationdate)) att 
WHERE  credIssue.CertCode = 'ICARD'
       AND credIssue.duration = 'Timelimited' 
       AND credIssue.expirationdate >= '1/1/2019' 
       AND att.memberguid IS NULL 
      
UNION 
--RULE Programs 006.3 
--The ICard Reattestation Due Date must be 12/31/<year of last re-attestation plus 5> when all of the following are true:
--        - The Certificate is a Time Limited Certificate (Program Rule: Time Limited Certificate)
--        - The Certificate expires in 2019 or later 
--        - A previous re-attestation exists for this Certificate between the start and end date of the Certificate

SELECT credIssue.memberid 
       memberGUID, 
       Datefromparts(Datepart(year, att.attestationinstancestatusdate) + 5, 12, 31) 
       DueDate, 
       'ICARDAttestMOC' 
       AttestationType 
FROM   dbo.credential_issuance credIssue 
       OUTER apply 
       (SELECT  i.memberguid, 
                                 i.attestationinstancestatusdate
                     AttestationInstanceStatusDate 
                    FROM   attestationinstance i
                    WHERE  i.attestationcode IN ( 'ICARDAttestMOC' ) 
                           AND i.attestationinstancestatuscode = 'APPROVED' 
                           AND i.memberguid = credIssue.memberid 
                           AND i.attestationinstancestatusdate >= 
                               credIssue.effectivedate 
                           AND i.attestationinstancestatusdate < Dateadd(d, 1, 
                               credIssue.expirationdate) 
                    ) att 
WHERE  credIssue.CertCode = 'ICARD' 
       AND credIssue.duration = 'Timelimited' 
       AND credIssue.expirationdate >= '1/1/2019' 
       AND att.memberguid IS NOT NULL 
 
UNION 
--RULE Programs 006.4 
--The ICard Reattestation Due Date must be 12/31/<initial certification year plus 5> when all of the following are true:
--      -  the certificate is MBM  (Program Rule: Must Be Mantained Certificate)
--      -  the certificate has never completed a re-attestation before.

SELECT credIssue.memberid 
       memberGUID, 
       Datefromparts(Datepart(year, credIssue.issuancedate) + 5, 12, 31) DueDate 
       , 
       'ICARDAttestMOC' 
       AttestationType 
FROM   dbo.credential_issuance credIssue 
       OUTER apply (SELECT i.memberguid 
                    FROM   attestationinstance i 
                    WHERE  i.attestationcode IN ( 'ICARDAttestMOC' ) 
                           AND i.attestationinstancestatuscode = 'APPROVED' 
                           AND i.memberguid = credIssue.memberid) att 
WHERE  credIssue.CertCode = 'ICARD'
       AND credIssue.duration = 'Continuous' 
	   AND credIssue.Occurrence = 'Initial'
       AND att.memberguid IS NULL 

UNION 
--RULE Programs 006.5
--The ICard Re-attestation Due Date must be 12/31/<last year of most recent re-attestation plus 5> when all of the following are true:
--      -  The Certificate is Must Be Maintained  (Program Rule: Must Be Mantained Certificate)
--      -  The Certificate has completed a re-attestation before

SELECT credIssue.memberid         memberGUID, 
       Datefromparts(Datepart(year, att.attestationinstancestatusdate ) 
                     + 5, 12, 31) DueDate, 
       'ICARDAttestMOC'           AttestationType 
FROM   dbo.credential_issuance credIssue 
       OUTER apply (SELECT i.memberguid, 
                          i.attestationinstancestatusdate
       AttestationInstanceStatusDate 
                    FROM   attestationinstance i 
                    WHERE  i.attestationcode IN ( 'ICARDAttestMOC' ) 
                           AND i.attestationinstancestatuscode = 'APPROVED' 
                           AND i.memberguid = credIssue.memberid 
                   ) att 
WHERE  credIssue.CertCode = 'ICARD' 
       AND credIssue.duration = 'Continuous' 
       AND att.memberguid IS NOT NULL  

GO


