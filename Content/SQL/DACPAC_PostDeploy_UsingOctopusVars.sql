
--THIS CREATES SYNONYMS AND A VIEW WHICH CAN FUNTION ACROSS DATABASES AND TENANTS.  
--A DBPREFIX IN OCTOPUS MIGHT BE "TENANT1_" OR "TENANT2_" FOR EXAMPLE.
Declare @dbprefix varchar(10),
@sql nvarchar(4000),
@objectid int


Set @dbprefix = replace('$(DbPrefix)', '_blank_', '')



select @objectid = object_id('dbo.UserAccounts', 'SN')

if @objectid is not null
begin
	Set @sql = 'drop synonym dbo.UserAccounts'
	Execute sp_executesql @sql
end

Set @sql = 'CREATE SYNONYM [dbo].[UserAccounts] FOR ' + @dbprefix + 'IdentityData.[dbo].[UserAccounts]'
Execute sp_executesql @sql



select @objectid = object_id('dbo.TrainingData', 'V')

if @objectid is not null
begin
	Set @sql = 'drop view dbo.TrainingData'
	Execute sp_executesql @sql
end

set @sql = 'CREATE VIEW dbo.TrainingData as
select 
    t.Name, t.ProgramType,
    ce.Status, ce.TrainingEndDate, ce.CompletionDate,
      c.abimid 
from  '
       + @dbprefix + 'CandidateTraining.dbo.TrainingSpecialty t, '
       + @dbprefix + 'CandidateTraining.dbo.AcademicYear a, '
       + @dbprefix + 'CandidateTraining.dbo.EvaluationForm e, '
       + @dbprefix + 'CandidateTraining.dbo.candidate c, '
       + @dbprefix + 'CandidateTraining.dbo.CandidateEvaluation ce
where
       t.TrainingSpecialtyId = e.TrainingSpecialtyId
and a.AcademicYearId = e.AcademicYearId
and e.EvaluationFormId = ce.EvaluationFormId
and c.candidateId = ce.candidateId'
 	
Execute sp_executesql @sql