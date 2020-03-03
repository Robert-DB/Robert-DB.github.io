USE [AttestationDatabase]
GO

/****** Object:  StoredProcedure [dbo].[DeleteAttestationInstance]    Script Date: 2/25/2020 9:42:47 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--THIS IS A CAREFUL, TRANSACTIONAL, DELETE OF AN ATTESTATION AND ALL OF IT'S DEPENDENT RECORDS IN VARIOUS TABLES.
--THE ATTESTATION_DATAMODEL.JPG CAN BE USED AS A REFERENCE.
CREATE PROCEDURE [dbo].[DeleteAttestationInstance]
(
@AttestationInstanceId UNIQUEIDENTIFIER,
@MemberGuid UNIQUEIDENTIFIER
)
AS 
BEGIN
SET XACT_ABORT ON

BEGIN TRANSACTION

DECLARE @Cnt AS INT
--Safety check - make sure the memberid is known and matches
SELECT @Cnt = COUNT(AttestationInstanceId)
FROM AttestationInstance
WHERE MemberGuid = @MemberGuid
  AND AttestationInstanceId = @AttestationInstanceId

IF @Cnt <> 1
BEGIN
  ROLLBACK TRANSACTION
  PRINT 'MemberGuid and InstanceId do not match.  Delete has been rolled back.'
  RETURN
END

PRINT 'BEGIN EMAIL LOG DELETE'
DELETE FROM AttestationEmailLog
WHERE AttestationInstanceId=@AttestationInstanceId
IF @@ROWCOUNT > 3
BEGIN
  ROLLBACK TRANSACTION
  PRINT 'ROLLBACK EMAIL LOG DELETE - Number of emails seems too high.  Please Investigate.'
  RETURN
END

PRINT 'BEGIN RESPONSE DELETE'
DELETE
FROM response
WHERE questionid IN (
    SELECT questionid
    FROM question
    WHERE attestationformid IN (
        SELECT attestationformid
        FROM attestationform
        WHERE attestationinstanceid = @AttestationInstanceId
        )
    )

IF @@ROWCOUNT > 1
BEGIN
  ROLLBACK TRANSACTION

  RETURN
END
PRINT 'BEGIN QUESTION DELETE'
DELETE
FROM question
WHERE attestationformid IN (
    SELECT attestationformid
    FROM attestationform
    WHERE attestationinstanceid = @AttestationInstanceId
    )

IF @@ROWCOUNT > 1
BEGIN
  ROLLBACK TRANSACTION

  RETURN
END
PRINT 'BEGIN PROCEDURELOG DELETE'
DELETE
FROM attestationprocedurelog
WHERE attestationformid IN (
    SELECT attestationformid
    FROM attestationform
    WHERE attestationinstanceid = @AttestationInstanceId
    )

PRINT 'BEGIN EVENT DELETE'
DELETE
FROM AttestationEvent
WHERE attestationformid IN (
    SELECT attestationformid
    FROM attestationform
    WHERE attestationinstanceid = @AttestationInstanceId
    )
PRINT 'BEGIN SET ATTESTORID TO NULL IN FORM'
UPDATE attestationform
SET attestorid = NULL
WHERE attestorid IN (
    SELECT attestorid
    FROM attestor
    WHERE attestationinstanceid = @AttestationInstanceId
    )

IF @@ROWCOUNT > 4
BEGIN
  ROLLBACK TRANSACTION

  RETURN
END

PRINT 'BEGIN ATTESTOR DELETE'
DELETE
FROM attestor
WHERE attestationinstanceid = @AttestationInstanceId

IF @@ROWCOUNT > 4
BEGIN
  ROLLBACK TRANSACTION

  RETURN
END
PRINT 'BEGIN FORM DELETE'
DELETE
FROM attestationform
WHERE attestationinstanceid = @AttestationInstanceId

IF @@ROWCOUNT > 5
BEGIN
  ROLLBACK TRANSACTION

  RETURN
END
PRINT 'BEGIN INSTANCE DELETE'
DELETE
FROM attestationinstance
WHERE attestationinstanceid = @AttestationInstanceId

IF @@ROWCOUNT > 1
BEGIN
  ROLLBACK TRANSACTION

  RETURN
END

PRINT 'completed successfully'

COMMIT TRANSACTION

END


GO


