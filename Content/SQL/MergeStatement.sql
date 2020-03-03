
use MergeDB



MERGE [dbo].[Correspondence] AS TARGET
USING    (SELECT (SELECT MemberId FROM UserProfile WHERE AbimId = 45566)
           ,'path'
           ,'Sent'
           ,getdate()
           ,'Email'
           ,'note'
           ,'line'
		   ,'SSIS Package'
        )
		AS SOURCE ([MemberId]
           ,[FilePath]
           ,[CorrespondenceAction]
           ,[CorrespondenceDate]
           ,[CorrespondenceType]
           ,[Note]
           ,[SubjectLine]
		   ,CreatedBy
     )
	 ON SOURCE.MemberId = TARGET.MemberId
	 AND SOURCE.FilePath = TARGET.FilePath
	 --IF THE MEMBERID,FILEPATH AND NOT MATCHED, AND THE MEMBERID IS PRESENT IN THE SOURCE, INSERT THE RECORD
	 WHEN NOT MATCHED 
	 AND SOURCE.MemberId IS NOT NULL 
	 THEN
	 INSERT 
           ([MemberId]
           ,[FilePath]
           ,[CorrespondenceAction]
           ,[CorrespondenceDate]
           ,[CorrespondenceType]
           ,[Note]
           ,[SubjectLine]
		   ,CreatedBy
     )
VALUES
(SOURCE.MemberId
           ,SOURCE.FilePath
           ,SOURCE.CorrespondenceAction
           ,SOURCE.CorrespondenceDate
           ,SOURCE.CorrespondenceType
           ,SOURCE.Note
           ,SOURCE.SubjectLine
		   ,SOURCE.CreatedBy
		   );


