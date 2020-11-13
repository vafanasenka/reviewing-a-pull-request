--get docusign doc
SELECT *
FROM 
DocumentManagement..TDocVersion dv with (nolock)
join DocumentManagement..TDocument td with (nolock) on dv.DocumentId = td.DocumentId
join [docusign].[dbo].[TDocument] docusign with (nolock) on td.DocumentId = docusign.DocumentId
--join crm..TCrmContact sender on docusign.SenderId = sender.CRMContactId
--join crm..TCRMContact signer on docusign.SignerId = signer.CRMContactId

where SentOn >= '2020-11-06 22:24:00.000'






Get Plans with inconsistency owners


select 
    PlanId
    ,TenantId
    ,pmpo.CRMContactId as 'TPolicyOwner CRMContactId'
    ,sdbpl.Owner1Id as 'sdb Plan Owner1Id'
    ,sdbpl.Owner2Id as 'sdb Plan Owner2Id'
    ,PlanTypeId
    ,PlanTypeValue
    ,PlanCategoryId
    ,PlanCategoryValue
    ,ProviderId
    ,SellingAdviserId
    ,IOBRef
    ,StatusId
    ,StatusValue
    ,PlanAdviceTypeId
    ,PlanAdviceTypeValue
    ,PortfolioPlanCategoryId
    ,PortfolioPlanCategoryValue
    ,PortfolioPlanSubCategoryId
    ,PortfolioPlanSubCategoryValue
    ,Deleted
    ,WhoCreatedUserId
from [sdb].[dbo].[Plan] sdbpl
    inner join [policymanagement].[dbo].[TPolicyBusiness] pmpb on sdbpl.PlanId = pmpb.PolicyBusinessId
    inner join [policymanagement].[dbo].[TPolicyOwner] pmpo on pmpb.PolicyDetailId = pmpo.PolicyDetailId
where sdbpl.Owner1Id <> pmpo.CRMContactId
    and sdbpl.Owner2Id <> pmpo.CRMContactId







PLAN OWNERS




declare @AdviserId int = 24890678    ----6181653
declare @ClientId int = 25362330     ----6180654
declare @PlanId int = 43936720          ----5070

create table #tempClients
(
    CRMContactId int
)

insert into #tempClients
select @AdviserId
insert into #tempClients
select @ClientId

insert into #tempClients
select CRMContactFromId
FROM [crm].[dbo].[TRelationship] r
  where r.IsPartnerFg = 1
  and (r.CRMContactFromId = @ClientId or r.CRMContactToId = @ClientId) 


--RELATIONSHIPS
SELECT TOP (1000)
    case when r.CRMContactFromId = @ClientId then 'from Client'
    else case when r.CRMContactToId = @ClientId then 'to Client'
    else 'Unknown' end end as 'RELATIONSHIP',
        [RelationshipId]
      ,[CRMContactFromId]
      ,[CRMContactToId]
      ,[IsPartnerFg]
      ,[IsFamilyFg]
      ,[IsPointOfContactFg]
      ,[IncludeInPfp]
      ,[ReceivedAccessType]
      ,[ReceivedAccessAt]
      ,[ReceivedAccessByUserId]
      ,[GivenAccessType]
      ,[GivenAccessAt]
      ,[GivenAccessByUserId]
  FROM [crm].[dbo].[TRelationship] r
  where r.IsPartnerFg = 1
  and (r.CRMContactFromId = @ClientId or r.CRMContactToId = @ClientId)

--USERS INFO
SELECT
    case when u.CRMContactId = @AdviserId then 'Adviser'
    else 'Client' end as 'USER INFO',
    c.PersonId, c.FirstName, c.LastName, u.CRMContactId, u.UserId, u.Identifier,
    a.AccountId, u.Email, u.groupId, a.Username, c.CurrentAdviserCRMId, c.CurrentAdviserName,
    rut.Identifier, u.RefUserTypeId
FROM  Crm..TCrmContact c
    JOIN Administration..TUser u on u.CRMContactId = c.CRMContactId
    JOIN Membership..TAccount a on a.Subject = u.Guid
    JOIN Administration..TRefUserType rut on rut.RefUserTypeId = u.RefUserTypeId
WHERE c.CRMContactId in (select * from #tempClients)

--RELATIONSHIPS KEYS
  select
  case
    when k.EntityId = @ClientId then 'to Client'
    else 'from Client to ->'
  end as 'KEY FOUND',
  c.FirstName + ' ' + c.LastName as 'Name',
  k.*
  from [crm].[dbo].[TCRMContactKey] k
    join Crm..TCrmContact c on k.EntityId = c.CRMContactId
  where EntityId in (select * from #tempClients)

--PLAN OWNERS
SELECT TOP (1000)
        po.[CRMContactId] as 'Owner CRMContactId'
      ,case when po.CRMContactId = @ClientId then 'Client owner'
      else 'Partner owner' end as 'OWNER',
        tb.[PolicyBusinessId]
      ,tb.[PolicyDetailId]
      ,[PolicyNumber]
      ,[PractitionerId]
      ,[AdviceTypeId]
      ,[PolicyStartDate]
      ,[BaseCurrency]
      --,[PlanValue]
      --,[PlanValueDate]
      --,[WhoUpdatedValue]
      --,[WhoUpdatedDateTime]
      ,mo.*
      ,inc.*
      ,mi.*
      ,ex.*
  FROM [policymanagement].[dbo].[TPolicyBusiness] tb
  --inner join [policymanagement].[dbo].[TPolicyBusinessExt] ext on tb.PolicyBusinessId = ext.PolicyBusinessId
  --left join [policymanagement].[dbo].[TPlanValuation] pv on tb.PolicyBusinessId = pv.PolicyBusinessId
  join [policymanagement].[dbo].[TPolicyOwner] po on tb.PolicyDetailId = po.PolicyDetailId
  left join [policymanagement].[dbo].[TPolicyMoneyOut] mo on tb.PolicyBusinessId = mo.PolicyBusinessId
  left join [factfind].[dbo].[TDetailedincomebreakdown] inc on tb.PolicyBusinessId = inc.PolicyBusinessId
  left join [policymanagement].[dbo].[TPolicyMoneyIn] mi on tb.PolicyBusinessId = mi.PolicyBusinessId
  left join [factfind].[dbo].[TExpenditureDetail] ex on tb.PolicyBusinessId = ex.PolicyBusinessId
  where tb.PolicyBusinessId = @PlanId
  
SELECT 
p.Owner1Id,
p.Owner2Id,
p.Owner3Id,
p.Owner4Id,
p.PolicyStartDate,
p.StatusDate,
p.SubmittedDate,
p.WhoCreatedUserId,
p.WhoUpdatedDateTime

FROM [sdb].[dbo].[Plan] p
where PlanId = @PlanId

If(OBJECT_ID('tempdb..#tempClients') Is Not Null)
Begin
    Drop Table #tempClients
End







OLD




SELECT TOP (100) this_.RelationshipId as y0_, reltype1_.RefRelationshipTypeId as y1_, reltype1_.RelationshipTypeName as y2_, correspond2_.RelationshipTypeName as y3_, correspond2_.RefRelationshipTypeId as y4_,
relfrom3_.CRMContactId as y5_, relto4_.CRMContactId as y6_, relfrom3_.IndClientId as y7_, relfrom3_.IsHeadOfFamilyGroup as y8_, relto4_.IsHeadOfFamilyGroup as y9_,
this_.IsFamilyFg as y10_, this_.IsPartnerFg as y11_, this_.IncludeInPfp as y12_, this_.GivenAccessType as y13_, this_.GivenAccessAt as y14_, this_.GivenAccessByUserId as y15_, this_.ReceivedAccessType as y16_,
this_.ReceivedAccessAt as y17_, this_.ReceivedAccessByUserId as y18_

FROM Crm.dbo.TRelationship this_
inner join Crm.dbo.TCRMContact relfrom3_ on this_.CRMContactFromId=relfrom3_.CRMContactId
left outer join CRM.dbo.VPerson relfrom3_1_ on relfrom3_.CRMContactId=relfrom3_1_.CRMContactId
left outer join CRM.dbo.VTrust relfrom3_2_ on relfrom3_.CRMContactId=relfrom3_2_.CRMContactId
left outer join CRM.dbo.VCorporate relfrom3_3_ on relfrom3_.CRMContactId=relfrom3_3_.CRMContactId
inner join Crm.dbo.TCRMContact relto4_ on this_.CRMContactToId=relto4_.CRMContactId
left outer join CRM.dbo.VPerson relto4_1_ on relto4_.CRMContactId=relto4_1_.CRMContactId
left outer join CRM.dbo.VTrust relto4_2_ on relto4_.CRMContactId=relto4_2_.CRMContactId
left outer join CRM.dbo.VCorporate relto4_3_ on relto4_.CRMContactId=relto4_3_.CRMContactId
inner join Crm.dbo.TRefRelationshipType reltype1_ on this_.RefRelTypeId=reltype1_.RefRelationshipTypeId
inner join Crm.dbo.TRefRelationshipType correspond2_ on this_.RefRelCorrespondTypeId=correspond2_.RefRelationshipTypeId WHERE relfrom3_.CRMContactId = 6181654 and reltype1_.AccountFg = 0 and correspond2_.AccountFg = 0




SELECT TOP (1000)
r.CRMContactFromId as [Owner CRM Id]
,[CRMContactId] as [Relation CRM Id]
,[RefCRMContactStatusId]
,[PersonId]
,[CorporateId]
--,[TrustId]
--,[AdvisorRef]
--,[RefSourceOfClientId]
--,[SourceValue]
,[Notes]
,[ArchiveFg]
,[IsDeleted]
,[LastName]
,[FirstName]
,[CorporateName]
,[DOB]
,c.[MigrationRef]
,[CreatedDate]
,[ExternalReference]
,[Postcode]
,[OriginalAdviserCRMId]
,[CurrentAdviserCRMId]
,[CurrentAdviserName]
,[CRMContactType]
,[IndClientId]
,[FactFindId]
,[InternalContactFG]
,[RefServiceStatusId]

,[CampaignDataId]
,[AdditionalRef]
,[AdviserAssignedByUserId]
,[_ParentId]
,[_ParentTable]
,[_ParentDb]
,[_OwnerId]
,c.[ConcurrencyId]
,[FeeModelId]
,[ServiceStatusStartDate]
,[ClientTypeId]
,[IsHeadOfFamilyGroup]
,[FamilyGroupCreationDate]






Query to find all relations for exact client




SELECT *
FROM [CRM].[dbo].[TRelationship]
where [CRMContactFromId] in (2584845)




Query to find relations between Deleted clients and active clients


FROM [CRM].[dbo].[TCRMContact] c
Inner join [CRM].[dbo].[TRelationship] r on c.CRMContactId = r.[CRMContactToId]
where
(ArchiveFg = 1 or IsDeleted = 1)
--and LastName like 'Undefined' and FirstName like 'Undefined'
and
r.CRMContactFromId in (2584845, 2585008, 10296809, 2584924, 9819715)

--and c.OriginalAdviserCRMId = 2531917
--and c.CRMContactId in (2584847,2584848)




Query from sql profiler to get relations




SELECT TOP (100) this_.RelationshipId as y0_, reltype1_.RefRelationshipTypeId as y1_, reltype1_.RelationshipTypeName as y2_, correspond2_.RelationshipTypeName as y3_, correspond2_.RefRelationshipTypeId as y4_,
relfrom3_.CRMContactId as y5_, relto4_.CRMContactId as y6_, relfrom3_.IndClientId as y7_, relfrom3_.IsHeadOfFamilyGroup as y8_, relto4_.IsHeadOfFamilyGroup as y9_,
this_.IsFamilyFg as y10_, this_.IsPartnerFg as y11_, this_.IncludeInPfp as y12_, this_.GivenAccessType as y13_, this_.GivenAccessAt as y14_, this_.GivenAccessByUserId as y15_, this_.ReceivedAccessType as y16_,
this_.ReceivedAccessAt as y17_, this_.ReceivedAccessByUserId as y18_

FROM Crm.dbo.TRelationship this_
inner join Crm.dbo.TCRMContact relfrom3_ on this_.CRMContactFromId=relfrom3_.CRMContactId
left outer join CRM.dbo.VPerson relfrom3_1_ on relfrom3_.CRMContactId=relfrom3_1_.CRMContactId
left outer join CRM.dbo.VTrust relfrom3_2_ on relfrom3_.CRMContactId=relfrom3_2_.CRMContactId
left outer join CRM.dbo.VCorporate relfrom3_3_ on relfrom3_.CRMContactId=relfrom3_3_.CRMContactId
inner join Crm.dbo.TCRMContact relto4_ on this_.CRMContactToId=relto4_.CRMContactId
left outer join CRM.dbo.VPerson relto4_1_ on relto4_.CRMContactId=relto4_1_.CRMContactId
left outer join CRM.dbo.VTrust relto4_2_ on relto4_.CRMContactId=relto4_2_.CRMContactId
left outer join CRM.dbo.VCorporate relto4_3_ on relto4_.CRMContactId=relto4_3_.CRMContactId
inner join Crm.dbo.TRefRelationshipType reltype1_ on this_.RefRelTypeId=reltype1_.RefRelationshipTypeId
inner join Crm.dbo.TRefRelationshipType correspond2_ on this_.RefRelCorrespondTypeId=correspond2_.RefRelationshipTypeId
--WHERE relfrom3_.CRMContactId in (2584845) and reltype1_.AccountFg = 0 and correspond2_.AccountFg = 0
WHERE relfrom3_.CRMContactId in (2584845) and reltype1_.AccountFg = 0 and correspond2_.AccountFg = 0




Query to get persons data which marked as Undefined with script




SELECT *
FROM [CRM].[dbo].[TPerson]
where PersonId in (2512616,2512617,2512694,2512695,2512778,10487878)










Query to find corrupted Pension Assets




declare @AssetIdIncrement int = 2000000000

select
--P.PlanId,
--p.TenantId,
--PR.Name AS ProviderName,
--P.PlanTypeValue,
--P.TotalPremiumsToDate,
--P.TotalWithdrawalsToDate,
--P.CurrentValuation,
--P.CurrentValuationDate,
--P.ProfitOrLossAmount,
--P.StatusValue,
--P.StatusId,
FH.FundHoldingId
--FH.Name AS FundHoldingName,
--FH.TypeValue AS HoldingType,
--fh.[LastUpdatedTimeStamp]

FROM
sdb..[Plan] P with(nolock)
--LEFT OUTER JOIN
--sdb..[Plan] PP ON P.ParentPlanId = PP.PlanId
--JOIN sdb..Provider PR with(nolock) ON P.ProviderId = PR.ProviderId AND PR.Deleted = 0
JOIN sdb..FundHolding FH with(nolock) ON P.PlanId = FH.PlanId --AND FH.Deleted = 0 AND FH.TypeValue like 'Asset'
left outer join [FactFind].[dbo].[TAssets] ffass with(nolock) on FH.FundHoldingId = (@AssetIdIncrement + ffass.AssetsId)
--LEFT OUTER JOIN
--sdb..Client C1 ON C1.ClientId = P.Owner1Id AND C1.TenantId = P.TenantId
--LEFT OUTER JOIN
--sdb..Client C2 ON C2.ClientId = P.Owner2Id AND C2.TenantId = P.TenantId
--LEFT OUTER JOIN
--sdb..Client C3 ON C3.ClientId = P.Owner3Id AND C3.TenantId = P.TenantId
--LEFT OUTER JOIN
--sdb..Client C4 ON C4.ClientId = P.Owner4Id AND C4.TenantId = P.TenantId
WHERE
P.PlanId in (45124401)
AND
P.Deleted = 0
AND P.IsTopUp = 0
AND P.IsWrapper = 1
AND FH.Deleted = 0 AND FH.TypeValue like 'Asset'

AND ffass.AssetsId is NULL










Get a Client with Relations AND get visible Assets

declare @TenantId int = 13409
declare @clientId int = 25948961
declare @IgnoreVisibilitySettings bit = 0

CREATE TABLE #ClientIds(CrmContactId INT)
INSERT INTO #ClientIds SELECT @clientId

INSERT INTO
#ClientIds
SELECT r.ToClientId
FROM sdb..Relationship r
WHERE r.FromClientId = @clientId and r.Deleted = 0 and r.IncludeInPfp = 1

CREATE CLUSTERED INDEX IDX_C2_Relatives_CrmContactId ON #ClientIds(CrmContactId)

select * from #ClientIds

SELECT
A.AssetId AS Id,
C1.ClientId AS Owner1Id,
C1.FirstName AS Owner1FirstName,
C1.FullName AS Owner1FullName,
C2.ClientId AS Owner2Id,
C2.FirstName AS Owner2FirstName,
C2.FullName AS Owner2FullName,
A.OwnerType as OwnerType,
A.AssetCategory AS Category,
A.AssetCategorySector AS IMASector,
[Description],
DatePurchased AS PurchaseDate,
PurchasePrice AS OriginalValue,
Value,
DateValued AS ValueDate,
A.ProfitLoss AS ProfitLoss,
A.ProfitLossPercent AS ProfitLossPercent,
A.PlanId AS RelatedPlanId,
A.IsVisibleToClient AS IsVisibleToClient,
A.WhoCreatedUserId AS WhoCreatedUserId,
P.PortfolioPlanCategoryValue AS PortfolioPlanCategoryValue

FROM
sdb..Asset A
LEFT OUTER JOIN
sdb..Client C1 ON C1.ClientId = A.OwnerId AND C1.TenantId = A.TenantId
LEFT OUTER JOIN
sdb..Client C2 ON C2.ClientId = A.Owner2Id AND C2.TenantId = A.TenantId
inner join #ClientIds CL on (A.OwnerId = CL.CrmContactId OR A.Owner2Id =CL.CrmContactId )
LEFT JOIN
sdb..[Plan] P ON P.PlanId = A.PlanId

WHERE
A.Deleted = 0 AND A.TenantId = @TenantId
AND
((A.IsVisibleToClient = 1) or @IgnoreVisibilitySettings = 1)
AND
(ISNULL(A.PlanId, 0) = 0 OR (P.IsVisibleToClient = 1))
--(ISNULL(A.PlanId, 0) = 0 OR (P.IsVisibleToClient = 1 AND P.PortfolioPlanCategoryValue = 'Mortgages'))


IF OBJECT_ID('tempdb.dbo.#ClientIds') IS NOT NULL
DROP TABLE #ClientIds




Get all plans of a Client




SELECT TOP (1000) [PlanId]
,[TenantId]
,[InForceDate]
,[IsTopUp]
,[MigrationRef]
,[Owner1Id]
,[PlanCategoryId]
,[PlanCategoryValue]
,[PlanTypeId]
,[PlanTypeValue]
,[PolicyNumber]
,[PolicyStartDate]
,[ProductName]
,[ProviderId]
,[SellingAdviserId]
,[IOBRef]
,[StatusId]
,[StatusValue]
,[TnCCoachNameId]
,[TotalPremiumstoDate]
,[TotalPremiumstoDateEmployer]
,[TotalPremiumsToDateSelf]
,[TotalLumpSum]
,[TotalRegularPremium]
,[PlanAdviceTypeId]
,[PlanAdviceTypeValue]
,[StatusDate]
,[LastUpdatedTimeStamp]
,[PortfolioPlanCategoryId]
,[PortfolioPlanCategoryValue]
,[PortfolioPlanSubCategoryId]
,[PortfolioPlanSubCategoryValue]
,[Deleted]
,[PortfolioPlanGroupTypeValue]
,[IsWrapper]
,[RootIOBRef]
,[CurrentValuationCreatedUserId]
,[IsInforceAlertReceived]
,[AgencyStatusId]
,[AgencyStatusValue]
,[RelatedSchemeContributionAmount]
,[RelatedSchemeRenewalDate]
,[RelatedSchemePaymentMethodId]
,[RelatedSchemePaymentMethodValue]
,[RelatedSchemePremiumFrequencyId]
,[RelatedSchemePremiumFrequencyValue]
,[RelatedSchemeRegisteredId]
,[RelatedSchemeRegisteredValue]
,[PremiumWaiverWoc1]
,[PremiumWaiverWoc2]
,[ProductPeriodId]
,[ProductPeriodValue]
,[IsTargetMarketId]
,[IsTargetMarketValue]
,[LastPlanChargeId]
,[ProductRatePeriodInYears]
,[RelatedFeeReference]
FROM [sdb].[dbo].[plan]
where TenantId = 13409
and (Owner1Id = 25948961)
and (IsWrapper = 1 or IsTopUp =1)




Get Portfolio Plans using stored procedure from ms.Portfolio




declare @TenantId int = 13409
declare @clientId int = 25948961
declare @IgnoreVisibilitySettings bit = 0

SELECT
P.PlanId AS Id,
P.BaseCurrency,
PR.Name AS ProviderName,
P.PlanTypeValue,
P.PlanTypeId,
P.ProductTypeId,
p.ProductTypeName,
p.ProductSubTypeId,
p.ProductSubTypeName,
P.PortfolioPlanCategoryValue,
P.PortfolioPlanSubCategoryValue,
P.PolicyNumber,
P.IOBRef,
P.MortgageLoanAmount,
P.TotalRegularPremium,
P.LifeCoverPaymentBasis,
P.CriticalIllnessAmount,
P.TotalPremiumsToDate,
P.TotalWithdrawalsToDate,
P.CurrentRegularPremiumFrequency,
P.CurrentValuation,
P.CurrentValuationDate,
P.CurrentValuationCreatedUserId,
P.CurrentValuationTypeValue,
P.WhoUpdatedDateTime,
P.WhoCreatedUserId,
P.GrowthPerAnnum,
P.ProfitOrLossAmount,
P.StatusValue,
P.StatusId,
P.InsuranceTypeValue,
P.GISumAssured,
P.MaturityDate,
P.ParentPlanId,
PP.PlanTypeValue AS ParentPlanType,
P.IsTopUp,
P.RenewalDate,
FH.FundHoldingId,
FH.Name AS FundHoldingName,
FH.TypeValue AS HoldingType,
FH.CITICODE,
FH.EpicCode,
FH.UnitsHolding,
FH.PriceDate,
FH.UnitsDate,
FH.Price AS FundPrice,
FH.Value AS FundValue,
FH.PriceUpdatedByUser as PriceUpdatedByUser,
FH.SectorCategoryValue AS FundSector,
C1.ClientId AS Owner1Id,
C1.FirstName AS Owner1FirstName,
C1.FullName AS Owner1FullName,
C2.ClientId AS Owner2Id,
C2.FirstName AS Owner2FirstName,
C2.FullName AS Owner2FullName,
C3.FirstName AS Owner3FirstName,
C3.FullName AS Owner3FullName,
C4.FirstName AS Owner4FirstName,
C4.FullName AS Owner4FullName,
P.LifeAssured1Name,
P.PremimumPaymentProtection1,
P.DisabilityCover1Value,
P.LifeAssured2Name,
P.PremimumPaymentProtection2,
P.DisabilityCover2Value,
P.BenefitAmount,
P.BenefitFrequencyValue,
P.LifeCoverTerm,
P.LifeCoverPaymentBasis,
P.LifeCoverIndexTypeValue,
P.BenefitsInTrust,
P.PolicyStartDate,
P.MaturityDate,
P.PortfolioPlanGroupTypeValue,
P.SplitBenefitAmount,
P.SplitBenefitFrequencyValue,
P.BenefitDeferredPeriod,
P.BenefitDeferredPeriodInterval,
P.SplitBenefitDeferredPeriod,
P.SplitBenefitDeferredPeriodInterval,
P.LifeCoverSumAssured,
P.CriticalIllnessAmount,
P.CriticalIllnessTerm,
P.IsConvertible,
P.IsRenewable,
P.IsPaymentProtection,
P.IsChildrensBeneft,
P.IsTerminalIllness,
P.GISumAssured,
P.GIAdditionalCover,
P.GIOwner2PercentageOfSumAssured,
P.WaitingPeriod,
P.BenefitPeriodValue,
p.BenefitPeriodOtherValue,
P.QualificationPeriodValue,
p.TotalPlanValuationTypeId AS TotalPlanValuationType,
NULL AS DisplaySubPlans,
NULL AS ShowGainLoss,
P.IsWrapper,
P.ValuationHistory,
P.PortalReference,
P.SystemPortalReference,
p.InForceDate,
p.IsJointExternal,
P.MortgagePriceValuation,
P.MonthlyMortgageRepaymentAmount,
P.MortgageValueOfProperty,
P.CurrentRegularPremium,
P.MortgageInterestRate,
P.IsVisibleToClient,
P.IsPlanValueVisibleToClient
FROM
sdb..[Plan] P
LEFT OUTER JOIN
sdb..[Plan] PP ON P.ParentPlanId = PP.PlanId
LEFT OUTER JOIN
sdb..Provider PR ON P.ProviderId = PR.ProviderId AND PR.Deleted = 0
LEFT OUTER JOIN
sdb..FundHolding FH ON P.PlanId = FH.PlanId AND FH.Deleted = 0
LEFT OUTER JOIN
sdb..Client C1 ON C1.ClientId = P.Owner1Id AND C1.TenantId = P.TenantId
LEFT OUTER JOIN
sdb..Client C2 ON C2.ClientId = P.Owner2Id AND C2.TenantId = P.TenantId
LEFT OUTER JOIN
sdb..Client C3 ON C3.ClientId = P.Owner3Id AND C3.TenantId = P.TenantId
LEFT OUTER JOIN
sdb..Client C4 ON C4.ClientId = P.Owner4Id AND C4.TenantId = P.TenantId
WHERE
P.PlanId in (45124401,
48222741,
48222774,
48222792,
48222817,
48222836,
48222948)
AND P.Deleted = 0
AND P.TenantId = @TenantId

UNION ALL SELECT
P1.PlanId AS Id,
P1.BaseCurrency,
PR.Name AS ProviderName,
P1.PlanTypeValue,
P1.PlanTypeId,
P1.ProductTypeId,
p1.ProductTypeName,
p1.ProductSubTypeId,
p1.ProductSubTypeName,
P1.PortfolioPlanCategoryValue,
P1.PortfolioPlanSubCategoryValue,
P1.PolicyNumber,
P1.IOBRef,
P1.MortgageLoanAmount,
P1.TotalRegularPremium,
P1.LifeCoverPaymentBasis,
P1.CriticalIllnessAmount,
P1.TotalPremiumsToDate,
P1.TotalWithdrawalsToDate,
P1.CurrentRegularPremiumFrequency,
P1.CurrentValuation,
P1.CurrentValuationDate,
P1.CurrentValuationCreatedUserId,
P1.CurrentValuationTypeValue,
P1.WhoUpdatedDateTime,
P1.WhoCreatedUserId,
P1.GrowthPerAnnum,
P1.ProfitOrLossAmount,
P1.StatusValue,
P1.StatusId,
P1.InsuranceTypeValue,
P1.GISumAssured,
P1.MaturityDate,
P1.ParentPlanId,
NULL AS ParentPlanType,
P1.IsTopUp,
P1.RenewalDate,
FH.FundHoldingId,
FH.Name AS FundHoldingName,
FH.TypeValue AS HoldingType,
FH.CITICODE,
FH.EpicCode,
FH.UnitsHolding,
FH.PriceDate,
FH.UnitsDate,
FH.Price AS FundPrice,
FH.Value AS FundValue,
FH.PriceUpdatedByUser as PriceUpdatedByUser,
FH.SectorCategoryValue AS FundSector,
C1.ClientId AS Owner1Id,
C1.FirstName AS Owner1FirstName,
C1.FullName AS Owner1FullName,
C2.ClientId AS Owner2Id,
C2.FirstName AS Owner2FirstName,
C2.FullName AS Owner2FullName,
C3.FirstName AS Owner3FirstName,
C3.FullName AS Owner3FullName,
C4.FirstName AS Owner4FirstName,
C4.FullName AS Owner4FullName,
P1.LifeAssured1Name,
P1.PremimumPaymentProtection1,
P1.DisabilityCover1Value,
P1.LifeAssured2Name,
P1.PremimumPaymentProtection2,
P1.DisabilityCover2Value,
P1.BenefitAmount,
P1.BenefitFrequencyValue,
P1.LifeCoverTerm,
P1.LifeCoverPaymentBasis,
P1.LifeCoverIndexTypeValue,
P1.BenefitsInTrust,
P1.PolicyStartDate,
P1.MaturityDate,
P1.PortfolioPlanGroupTypeValue,
P1.SplitBenefitAmount,
P1.SplitBenefitFrequencyValue,
P1.BenefitDeferredPeriod,
P1.BenefitDeferredPeriodInterval,
P1.SplitBenefitDeferredPeriod,
P1.SplitBenefitDeferredPeriodInterval,
P1.LifeCoverSumAssured,
P1.CriticalIllnessAmount,
P1.CriticalIllnessTerm,
P1.IsConvertible,
P1.IsRenewable,
P1.IsPaymentProtection,
P1.IsChildrensBeneft,
P1.IsTerminalIllness,
P1.GISumAssured,
P1.GIAdditionalCover,
P1.GIOwner2PercentageOfSumAssured,
P1.WaitingPeriod,
P1.BenefitPeriodValue,
p1.BenefitPeriodOtherValue,
P1.QualificationPeriodValue,
NULL AS TotalPlanValuationType,
NULL AS DisplaySubPlans,
NULL AS ShowGainLoss,
P1.IsWrapper,
P1.ValuationHistory,
P1.PortalReference,
P1.SystemPortalReference,
P1.InForceDate,
P1.IsJointExternal,
P1.MortgagePriceValuation,
P1.MonthlyMortgageRepaymentAmount,
P1.MortgageValueOfProperty,
P1.CurrentRegularPremium,
P1.MortgageInterestRate,
P1.IsVisibleToClient,
P1.IsPlanValueVisibleToClient
FROM
sdb..[Plan] P1
LEFT OUTER JOIN
sdb..[Plan] PP on P1.ParentPlanId = PP.PlanId
LEFT OUTER JOIN
sdb..Provider PR ON P1.ProviderId = PR.ProviderId AND PR.Deleted = 0
LEFT OUTER JOIN
sdb..FundHolding FH ON P1.PlanId = FH.PlanId AND FH.Deleted = 0
LEFT OUTER JOIN
sdb..Client C1 ON C1.ClientId = P1.Owner1Id AND C1.TenantId = P1.TenantId
LEFT OUTER JOIN
sdb..Client C2 ON C2.ClientId = P1.Owner2Id AND C2.TenantId = P1.TenantId
LEFT OUTER JOIN
sdb..Client C3 ON C3.ClientId = P1.Owner3Id AND C3.TenantId = P1.TenantId
LEFT OUTER JOIN
sdb..Client C4 ON C4.ClientId = P1.Owner4Id AND C4.TenantId = P1.TenantId
WHERE
P1.PlanId in (45124401,
48222741,
48222774,
48222792,
48222817,
48222836,
48222948)
AND P1.Deleted = 0
AND P1.TenantId = @TenantId
AND P1.IsTopUp = 1




Check sdb..FundHolding table and sdb..FundHoldingToClient table using FundHoldingId




SELECT TOP (1000) [FundHoldingId]
,[TenantId]
,[PlanId]
,[TypeId]
,[TypeValue]
,[IsFeed]
,[SectorCategoryId]
,[SectorCategoryValue]
,[UnitsHolding]
,[UnitsDate]
,[Price]
,[PriceDate]
,[Value]
,[ISIN]
,[SEDOL]
,[MEXID]
,[ProviderCode]
,[ProviderId]
,[FundTypeId]
,[FundTypeValue]
,[FundUnitId]
,[EquityId]
,[NonFeedFundId]
,[Name]
,[FundSuperSectorId]
,[FundSuperSectorValue]
,[FundIncomeYield]
,[LastUpdatedTimeStamp]
,[CITICODE]
,[Deleted]
,[EpicCode]
,[PriceUpdatedByUser]
,[CategoryId]
,[CategoryValue]
FROM [sdb].[dbo].[FundHolding]

where TenantId = 13409
and PlanId in (45124401,
48222741,
48222774,
48222792,
48222817,
48222836,
48222948)
and FundHoldingId in (2003228623,
2003627659)

SELECT TOP (1000) [FundHoldingToClientId]
,[TenantId]
,[FundHoldingId]
,[ClientId]
,[LastUpdatedTimeStamp]
,[Deleted]
FROM [sdb].[dbo].[FundHoldingToClient]
where TenantId = 13409
and ClientId = 25948961
and FundHoldingId in (2003228623,2003627659)




Get Assets by Owner Id




select top (10) *
from sdb..Asset
where OwnerId = 25948961










GET ASSETS




CREATE TABLE #ClientIds(CrmContactId INT)
INSERT INTO #ClientIds SELECT @clientId

INSERT INTO
#ClientIds
SELECT r.ToClientId
FROM Relationship r
WHERE r.FromClientId = @clientId and r.Deleted = 0 and r.IncludeInPfp = 1

CREATE CLUSTERED INDEX IDX_C2_Relatives_CrmContactId ON #ClientIds(CrmContactId)




SELECT
A.AssetId AS Id,
C1.ClientId AS Owner1Id,
C1.FirstName AS Owner1FirstName,
C1.FullName AS Owner1FullName,
C2.ClientId AS Owner2Id,
C2.FirstName AS Owner2FirstName,
C2.FullName AS Owner2FullName,
A.OwnerType as OwnerType,
A.AssetCategory AS Category,
A.AssetCategorySector AS IMASector,
[Description],
DatePurchased AS PurchaseDate,
PurchasePrice AS OriginalValue,
Value,
DateValued AS ValueDate,
A.ProfitLoss AS ProfitLoss,
A.ProfitLossPercent AS ProfitLossPercent,
A.PlanId AS RelatedPlanId,
A.IsVisibleToClient AS IsVisibleToClient,
A.WhoCreatedUserId AS WhoCreatedUserId,
P.PortfolioPlanCategoryValue AS PortfolioPlanCategoryValue

FROM
Asset A
LEFT OUTER JOIN
Client C1 ON C1.ClientId = A.OwnerId AND C1.TenantId = A.TenantId
LEFT OUTER JOIN
Client C2 ON C2.ClientId = A.Owner2Id AND C2.TenantId = A.TenantId
inner join #ClientIds CL on (A.OwnerId = CL.CrmContactId OR A.Owner2Id =CL.CrmContactId )
LEFT JOIN
[Plan] P ON P.PlanId = A.PlanId

WHERE
A.Deleted = 0 AND A.TenantId = @TenantId
AND
((A.IsVisibleToClient = 1) or @IgnoreVisibilitySettings = 1)
AND
(ISNULL(A.PlanId, 0) = 0 OR (P.IsVisibleToClient = 1 AND P.PortfolioPlanCategoryValue = 'Mortgages'))

IF OBJECT_ID('tempdb.dbo.#ClientIds') IS NOT NULL
DROP TABLE #ClientIds




Get assets info




SELECT TOP (1000) [AssetId]
,[TenantId]
,[OwnerId]
,[Description]
,[Value]
,[DateValued]
,[PlanId]
,[AssetCategory]
,[AssetCategorySector]
,[PercentOwnership]
,[LastUpdatedTimeStamp]
,[Deleted]
,[OwnerType]
,[Owner2Id]
,[IsVisibleToClient]
FROM [sdb].[dbo].[Asset]
where
TenantId = 10942
and AssetCategory like 'Cash'
and OwnerId = 9653270
and Description like 'Cash ISA portfolio'




SELECT TOP (1000) [AssetsId]
,[CRMContactId]
,[CRMContactId2]
,[Owner]
,[Description]
,[Amount]
,[ValuedOn]
,[PriceUpdatedByUser]
,[Type]
,[PurchasePrice]
,[PurchasedOn]
,[loanamount]
,[investmentprop]
,[PolicyBusinessId]
,[AssetCategoryId]
,[percentOwnership]
,[RelatedtoAddress]
,[ConcurrencyId]
,[IsVisibleToClient]
,[WhoCreatedUserId]
,[AssetMigrationRef]
,[RefCountyId]
,[RefCountryId]
,[percentOwnershipCrmContact2]
,[AddressLine2]
,[AddressLine3]
,[AddressLine4]
,[AddressCityTown]
,[AddressPostCode]
FROM [FactFind].[dbo].[TAssets]
where
CRMContactId = 9653270
or
AssetsId = 677309




Normally records into this tables are syncronized










SELECT TOP (1000) [ProductInstanceId]
,[ProductTypeId]
,[ProductTypeSKU]
,[ProductTypeName]
,[ProductTypeDescription]
,[Discriminator]
,[Claim]
,[Token]
,[IsActive]
,[ProfileId]
,[PayerId]
,[OwnerId]
,[AgreedPriceId]
,[PriceFrequency]
,[PriceNetAmount]
,[TrialAvailable]
,[DateCreated]
,[DateExpired]
FROM [payment].[dbo].[TProductInstance]
where IsActive = 1
order by DateCreated desc










TenantID: 11572 

client (11833989-13008934)

ExplicitConsentDirectMarketing_v318426_20180618123819

one is PDF and one is Word




ExplicitConsentDirectMarketing_v318426_20180618123819.docx is 
Production Unsigned and shared. 18/06/2018 12:39:02 




ExplicitConsentDirectMarketing_v318426_20180618123819.pdf is production signed and not shared. 19/06/2018 00:04:11 
You cannot open this one





SELECT
TD.IsESignature,
DV.DocVersionId,
DV.[CreatedDate],
DV.DocumentId,
DV.[Version],
DV.Status,
DV.[FileName],
DV.OriginalFileName,
DV.PfpDocumentId,
CASE WHEN (DV.PfpDocumentId IS NOT NULL)
THEN CAST(1 AS bit)
ELSE CAST(0 AS bit)
END AS Shared,
CASE WHEN (CS.DocumentId IS NOT NULL)
THEN CAST(1 AS bit)
ELSE CAST(0 AS bit)
END AS HasClientStorage,
CS.DateCreated,
CS.DateShared,
CS.OwnerId,
DV.CreatedByUserId,
CRM.CRMContactId,
(CRM.FirstName + ' ' + CRM.LastName) as [Client],
CRM.DOB,
CRM.CurrentAdviserCRMId,
CRM.CurrentAdviserName

FROM [DocumentManagement].[dbo].[TDocVersion] DV WITH(NOLOCK)
INNER JOIN [documentmanagement].[dbo].[TDocument] TD WITH (NOLOCK) ON DV.DocumentId = TD.DocumentId
INNER JOIN [DocumentManagement].[dbo].TDocumentOwner DO WITH(NOLOCK) ON DV.DocumentId = DO.DocumentId
INNER JOIN [CRM].[dbo].[TCRMContact] CRM WITH(NOLOCK) ON DO.CRMContactId = CRM.CRMContactId
LEFT OUTER JOIN [ClientStorage].[dbo].[Metadata] CS ON DV.PfpDocumentId = CS.DocumentId

WHERE
TD.IsESignature = 1
AND
DV.Status like 'Production Signed'
AND
DV.PfpDocumentId IS NULL













TTemplateWorkflow
TOutput.Data
TReview.Data
TTemplateVersion.Data




SELECT COUNT(*)
FROM [dbo].TTemplateVersion
WHERE Definition IS NOT NULL

261651




SELECT COUNT(*)
FROM [dbo].[TReview]
WHERE [Data] IS NOT NULL

2129264




SELECT COUNT(*)
FROM [dbo].[TOutput]
WHERE [Data] IS NOT NULL

2148381




SELECT TOP 10 *
FROM [author2].[dbo].[TTemplateWorkflow]
ORDER BY DateCreated desc

10

the latest DateCreated=2016-02-06 08:06:43.000




*****

Brand & Hostname

SELECT TOP (1000) [BrandId]

,[TenantId]
,[GroupId]
,[Application]
,[Hostname]
FROM [brand].[dbo].[TBrand]
where Hostname like 'eclipsefinancialsolutionsltd.mypfp.co.uk%'

SELECT
LEN([Hostname]) as 'Hostname Lenght'
FROM [brand].[dbo].[TBrand]
where Hostname like 'eclipsefinancialsolutionsltd.mypfp.co.uk%'







SELECT TOP (1000) [GroupLicenceId]
,[Host]
,[LicenceCount]
,[AvailableLicenceCount]
,[TenantGuid]
,[GroupId]
FROM [SaleMove].[dbo].[TGroupLicence]
--where GroupId = 17379
where Host like 'eclipsefinancialsolutionsltd.mypfp.co.uk%'

SELECT
LEN([Host]) as 'Hostname Lenght'
FROM [Administration].[dbo].[TDomain]
where Host like 'eclipsefinancialsolutionsltd.mypfp.co.uk%'







SELECT TOP (1000) [DomainId]
,[GroupId]
,[Host]
,[Application]
FROM [Administration].[dbo].[TDomain]
where Host like 'eclipsefinancialsolutionsltd.mypfp.co.uk%'
--where [GroupId] = 17379

SELECT
LEN([Host]) as 'Hostname Lenght'
FROM [Administration].[dbo].[TDomain]
where Host like 'eclipsefinancialsolutionsltd.mypfp.co.uk%'










=====

SaleMove ticket

CRMContactId
21573673
PersonId
19904356
LastName
Undefined
FirstName
Undefined
DOB
1900-01-01 00:00:00.000
IndClientId
12604







***

get funds + isin

select tf.Name
,tf.CrownRating
,res.ISINCode

from
(

SELECT TOP (1000000)
FundId,
ISINCode

FROM [Fund2].[dbo].[TFundUnit]
where ISINCode <> ''
group by ISINCode, FundId
having count (ISINCode) = 1 and COUNT (FundId) = 1
) as res

INNER JOIN
[Fund2].[dbo].[TFund] tf
ON res.FundId = tf.FundId

ORDER BY Name




***

check DocumentOwner (joint doc or not)

SELECT TOP (1000) [DocumentOwnerId]
,DO.[DocumentId]
,DOC.OriginalFileName
,CRM.CRMContactId
,CRM.PersonId
,CRM.LastName
,CRM.FirstName
,CRM.DOB
,CRM.CurrentAdviserCRMId
,CRM.CurrentAdviserName
,CRM.ClientTypeId
FROM [DocumentManagement].[dbo].[TDocumentOwner] DO with(nolock)
JOIN [CRM].[dbo].[TCRMContact] CRM with(nolock) on DO.CRMContactId = CRM.CRMContactId
JOIN [DocumentManagement].[dbo].[TDocument] DOC on DO.DocumentId = DOC.DocumentId
where DOC.DocumentId=114299120

***


*****

check ClientStorage doc

declare @docversionid int
set @docversionid = 115770410

SELECT

DV.DocVersionId,
DV.[CreatedDate],
DV.DocumentId,

DO.CRMContactId,

DV.[Version],

DV.[FileName],

DV.OriginalFileName,

DV.PfpDocumentId,

CASE WHEN (DV.PfpDocumentId IS NOT NULL)

THEN CAST(1 AS bit)

ELSE CAST(0 AS bit)

END AS Shared,

CASE WHEN (CS.DocumentId IS NOT NULL)

THEN CAST(1 AS bit)

ELSE CAST(0 AS bit)

END AS HasClientStorage,
CS.DateCreated,
CS.DateShared,
CS.OwnerId,

DV.CreatedByUserId,
CRM.LastName, CRM.FirstName, CRM.DOB, CRM.CurrentAdviserCRMId, CRM.CurrentAdviserName

FROM [DocumentManagement].[dbo].TDocVersion DV with(nolock)

JOIN [DocumentManagement].[dbo].TDocumentOwner DO with(nolock) on DV.DocumentId = DO.DocumentId

JOIN [CRM].[dbo].[TCRMContact] CRM with(nolock) on DO.CRMContactId = CRM.CRMContactId

LEFT OUTER JOIN [ClientStorage].[dbo].[Metadata] CS on DV.PfpDocumentId = CS.DocumentId

WHERE

DV.DocVersionId = @docversionid
AND DV.PfpDocumentId IS NOT NULL
AND CS.DocumentId IS NOT NULL

***




*****

Notification settings


SELECT TOP (1000) [NotificationSettingId]
,[UserId]
,[TenantId]
,[NotifyOnReceipt]
,[AutoReplyEnabled]
,[AutoReplyTimeLimited]
,[AutoReplyStartsOn]
,[AutoReplyEndsOn]
,[AutoReplyMessageBody]
FROM [securemessage].[dbo].[TSecureMessageNotificationSetting]
where TenantId = 793
--where UserId = 21792




***** 

check USer's email and contacts

SELECT TOP (1000) [UserId],
[Email] as '[TUser].[Email]'
,c.Value as '[TContact].Value'
,[ExpirePasswordOn]
,u.[CRMContactId]
,[Identifier]
,[SuperUser]
,[SuperViewer]
,u.[ConcurrencyId]
,c.ConcurrencyId
,[EmailConfirmed]

FROM [Administration].[dbo].[TUser] u
JOIN [CRM].[dbo].[TContact] c ON u.CRMContactId = c.CRMContactId
where UserId = 120561
AND c.RefContactType = 'E-Mail'
--AND [Email] <> c.Value

***




check Secure Messages

SELECT TOP (1000) [SecureMessageId]
,[Subject]
,[Body]
,[BodyPreview]
,[SenderPartyId]
,c.Value
,[Status]
,[SentTimeStamp]
,[ReceivedTimeStamp]
,[IsRead]
,[ReadOnTimeStamp]
,[SenderName]
,[SentMessageId]
,[ReceivedMessageId]
,[UpdatedDraftTimeStamp]
FROM [securemessage].[dbo].[TSecureMessage] m
join [CRM].[dbo].[TContact] c ON m.SenderPartyId = c.CRMContactId
where
--TenantId = 793
--and SenderName like '%gilles%'
SenderPartyId IN (22431895)
and c.RefContactType = 'E-Mail'
order by [SecureMessageId]




***




AA ticket




Automated Advice - Suitability Report v11




SELECT DV.DocumentId, DV.CreatedDate, DV.LastUpdatedDate, DV.LastUserId, DV.Status, DV.LastAction,
DV.OriginalFileName, DV.PfpDocumentId, TD.Identifier, TD.Descriptor, TD.OriginalFileName,
TD.EntityId, TD.EntityDescriptor, TD.ConcurrencyId, TD.IsESignature, TD.IsPrivate

FROM [documentmanagement].[dbo].[TDocVersion] DV WITH (NOLOCK)  inner join [documentmanagement].[dbo].[TDocument] TD WITH (NOLOCK) on DV.DocumentId = TD.DocumentId
where 
DV.IndigoClientId = 12698
and
TD.OriginalFileName in ('FactFindElectronicAgreement_v359651_20181219143539_certificate.pdf',
'FactFindElectronicAgreement_v359651_20181219143539.pdf', 'FactFindElectronicAgreement_v359651_20181219142116.pdf',
'FactFindElectronicAgreement_v359651_20181219133352.pdf', 'FactFindElectronicAgreement_v359176_20181219105019.pdf')




Claims




Type Value
birthdate 7/9/1983 12:00:00 AM
email torphinaatest@mailinator.com
family_name AAdvice
given_name Torphin
group_id 9697
group_lineage 9697
name Torphin AAdvice
ni_number NZ652407C
party_id 25539894
pfp_domain torphinassociatesltd.mypfp.co.uk
pfp_premium False
pgi 9697
srv_adviser_name Grant Macdonald
srv_adviser_party_id 18529959
srv_adviser_subject 1527ea5b-2cae-4772-bd11-a6d400e3e0c1
ssi 34083
sub 14488ad6-3980-4784-9345-a9fa010aca81
tel 012345678910
tenant_guid 896f14b7-59c4-4547-ba90-63b99e626de0
tenant_id 12234
user_id 201578
username 14488ad6-3980-4784-9345-a9fa010aca81




[Author].[dbo].[TTemplate]
where DocumentId = 69595

No records




15/03/2019

Tenant: Nest Egg (Part of PP Wealth)
ID: 11404




***

get user data by CRM id

SELECT top 1000
c.CRMContactId, c.PersonId, c.LastName, c.FirstName, c.DOB, c.Postcode, c.OriginalAdviserCRMId, c.CurrentAdviserCRMId, c.CurrentAdviserName,
c.CRMContactType, c.IndClientId, c.InternalContactFG, c.RefServiceStatusId, c.MigrationRef, c.CreatedDate, c.ExternalReference, c.CampaignDataId,
c.AdditionalRef, c.AdviserAssignedByUserId, c._OwnerId, c.FeeModelId, c.ServiceStatusStartDate, c.ClientTypeId, c.IsHeadOfFamilyGroup, c.FamilyGroupCreationDate,
c.IsDeleted,
u.UserId, u.Identifier, u.RefUserTypeId, u.Guid, u.Password as [UserPassword], u.PasswordSalt as [UserPasswordSalt], u.SyncPassword, u.ExpirePasswordOn,
u.Email as [UserEmail], u.EmailConfirmed, u.Status, u.GroupId, u.Telephone, u.Reference,
u.CanLogCases,
a.AccountId, a.Subject, a.Username, a.Email as [AccountEmail], a.IsLoginAllowed, a.IsAccountVerified, a.Password as [AccountPassword], a.PasswordSalt as [AccountPasswordSalt],
a.PasswordAlgorithm, a.PasswordChanged, a.LastLogin, a.LastFailedLogin, a.LastLockedOutDate, a.Created, a.LastUpdated, a.SyncDate,
rut.RefUserTypeId, rut.Identifier, rut.Url, rut.ConcurrencyId
--c.PersonId, u.CRMContactId, u.UserId, a.AccountId, u.Email, u.groupId, c.PersonId, a.Username, rut.Identifier, u.Guid

FROM crm..TCrmContact c

JOIN [administration].[dbo].[TUser] u on u.CRMContactId = c.CRMContactId

JOIN Membership..TAccount a on a.Subject = u.Guid

JOIN [administration].[dbo].[TRefUserType] rut on rut.RefUserTypeId = u.RefUserTypeId

Where
c.IndClientId = 11404
and
(ExternalReference like '18702844-25648117'
)




get user's account data by Email

SELECT TOP (1000) [AccountId]

,[Subject]
,[Username]
,[Email]
,[IsLoginAllowed]
,[IsAccountVerified]
,[Password]
,[PasswordSalt]
,[PasswordAlgorithm]
,[PasswordChanged]
,[LastLogin]
,[LastFailedLogin]
,[FailedLoginCount]
,[LastLockedOutDate]
,[LastFailedPasswordReset]
,[FailedPasswordResetCount]
,[Created]
,[LastUpdated]
,[SyncOrigin]
,[SyncDate]
FROM [Membership].[dbo].[TAccount]
where Email like 'wealth123@mailinator.com'




get claims by account id

select * from

[Membership].[dbo].[TClaim]
where AccountId = 158647




get payment messages by subject GUID

SELECT * FROM simpleadviceaegon..TTenantConfiguration

where TenantId = 11404

SELECT *
FROM [simpleadviceaegon].[dbo].[TPaymentMessage]
where Subject in ('3B8D1BA2-3005-449D-97BD-AA1100CB92F6')


SELECT TOP (1000) [AdviserRateId]
,[CompanyReference]
,[SegmentName]
,[Rate]
,[CreatedOn]
,[UpdatedOn]
FROM [simpleadviceaegon].[dbo].[TAdviserRate]
where CompanyReference like '153051'













///////////////////////////////


> Go to https://mynestegg.mypfp.co.uk/planningandadvice
> Accept conditions and press tick boxes
> Start Planning 
> Logs in as existing iO Client and PFP User
> Completes Journey up until the point of adding details

Gets stuck on the 'confirm your details page' (Screenshot attached). 

The client in iO is 
(18702844-25648117)




Mar 14 11:57:09 prd-10-ms15 Microservice.SimpleAdviceAegon.exe: a_level=ERROR, a_logger=Microservice.SimpleAdviceAegon.v1.Payment.Aegon.Client.PaymentClientProxy, a_time="2019-03-14 11:57:08,952", a_sub="(null)", a_uid="208798", a_tid="11404", a_rid="784d94b5-84be-4baa-b7c8-d31224da3b70", a_errid="(null)", a_aname="Microservice.SimpleAdviceAegon", a_aver="1.135.111.1", a_thread="16", a_type="Microservice.SimpleAdviceAegon.v1.Payment.Aegon.Client.PaymentClientProxy+<GetIllustration>d__3", a_met="MoveNext", a_msg="Aegon operation has failed with following errors:Code = E010, Reason = Buy Top-Up: Where supplied agency_number must be recognized by COFUNDS.; ", a_stack="", a_area="(null)", a_areatype="(null)"

SessionId=d2ee4725-69af-4b72-8e4d-f8fa0239b48a
SessionId=56f7be48-83f3-405b-9b6e-99fb531b175e
SessionId=a88d63c2-3989-4e08-9f49-82bd58a3af89




AccountIds which produces errors for the Client

[accounts].[dbo].[TAccount] 

397427 Hargreaves Lansdown (UK) LinkedPlanId=44041597
332354 Nutmeg (UK) LinkedPlanId=41488214

Container='InvestmentAccount'

AccountCategory='investments'




[sdb].[dbo].[plan]

PlanCategoryValue='Retail Investments'

PlanTypeValue='General Investment Account'

PortfolioPlanCategoryId=1

PortfolioPlanCategoryValue='Investments'

PortfolioPlanSubCategoryId=13

PortfolioPlanSubCategoryValue='General Investment Account'

ProductTypeId=114

ProductTypeName='General Investment Account'




Valuations

select *
from [dbo].[TPlanValuation]
where PolicyBusinessId
in (
44041597
)





TAccount

397427 4600 InvestmentAccount 44844045 19303358 11232 Hargreaves Lansdown (UK) -1650315832 NULL investments stockBasket xx8763 Stocks & Shares ISA NULL 0 1 2019-02-06 13:35:49.000 132790 2019-03-11 01:42:50.000 132790 44041597 1 1 2019-03-11 01:42:37.000 0 4600 22471329 132790 12628 4D75C369-0BAC-4DC3-8C7D-A89E0111BAA6 29247536797a44bf9c90f41eaaefc0c5 2iGZfEOpDytwMAOffPk7EqnshdBZPJuPTTKxEQJk8uM= 2018-07-04 12:16:59.000 132790 2018-07-04 12:16:59.000 132790 0




step 1

SELECT TOP (100) *

FROM [accounts].[dbo].[TAccount] as ac

inner join [accounts].[dbo].[TAccountRegistration] as reg

on ac.AccountRegistrationId = reg.AccountRegistrationId


where

reg.TenantId = 12628

and

reg.[ClientId] = 22471329

and

(ac.YodleeSiteName like 'Hargreaves Lansdown%'
--or ac.YodleeSiteName like 'Nutme%'
)




we check acc from ticket and acc with the same meaning ibnto the same client (can get it from an image attached)

we can get LinkedPlanId from here

YodleeSiteName
Hargreaves Lansdown (UK)

LinkedPlanId
44041597




SELECT *
FROM [sdb].[dbo].[plan]
where

-- error Id (why?)
--PlanId = 43197545
--or
--ParentPlanId = 43197545

-- acc to compare
--PlanId = 41488214
--or
--ParentPlanId = 41488214

-- acc from ticket
--or
PlanId = 44041597
or ParentPlanId = 44041597

--select * from [sdb].[dbo].PlanToClient
--where [ClientId] = 22471329
--and PlanId = 43197545




There is Plan with PlanId = 44041597 into [sdb].[dbo].[plan]

There is NO Plan with PlanId = 43197545 !!! Can't see details because of it?




select *
from [PolicyManagement].[dbo].[TPolicyBusiness]
where
--[IndigoClientId] = 12628
--and
--[PolicyBusinessId] = 43197545
--or
[PolicyBusinessId] = 44041597




There is Plan with PlanId = 44041597 into [PolicyManagement].[dbo].[TPolicyBusiness]

so there is Plan with PlanId = 43197545







select top(100) * from [sdb].[dbo].Provider
where Name
like 'Hargreaves%'

ProviderId Name Address Telephone IsArchived LastUpdatedTimeStamp Deleted
156 Hargreaves Lansdown 1 College Square South Anchor Road BS1 5HL NULL 0 2017-04-05 14:37:46.690 0







SELECT TOP (100) *

FROM [accounts].[dbo].[TAccount] as ac

inner join [accounts].[dbo].[TAccountRegistration] as reg

on ac.AccountRegistrationId = reg.AccountRegistrationId


where

reg.TenantId = 12628

and

reg.[ClientId] = 22471329

and

ac.YodleeSiteName like 'Hargreaves Lansdown%'







SQLs process flow

[documentmanagement]

SELECT DV.DocumentId, DV.CreatedDate, DV.LastUpdatedDate, DV.LastUserId, DV.Status, DV.LastAction,
DV.OriginalFileName, DV.PfpDocumentId, TD.Identifier, TD.Descriptor, TD.OriginalFileName,
TD.EntityId, TD.EntityDescriptor, TD.ConcurrencyId, TD.IsESignature, TD.IsPrivate

FROM [documentmanagement].[dbo].[TDocVersion] DV WITH (NOLOCK)
inner join [documentmanagement].[dbo].[TDocument] TD WITH (NOLOCK) on DV.DocumentId = TD.DocumentId
where
DV.IndigoClientId = 12698
and
TD.OriginalFileName in ('FactFindElectronicAgreement_v359651_20181219143539_certificate.pdf',
'FactFindElectronicAgreement_v359651_20181219143539.pdf', 'FactFindElectronicAgreement_v359651_20181219142116.pdf',
'FactFindElectronicAgreement_v359651_20181219133352.pdf', 'FactFindElectronicAgreement_v359176_20181219105019.pdf')

can find Documents and their Ids by doc names
can check IO status
can check PfpDocumentId, if there is PfpDocumentId - this document was signed




2. [docusign]

SELECT TOP (1000) [Id],[EnvelopeId],[SentOn],[DocumentId],[TenantId],[SignerId],[SenderId],[Status],[SigningFinishedOn],[SenderUserId],[SignedDocumentId],[ClientDocumentId],[SignedClientDocumentId]
FROM [docusign].[dbo].[TDocument]
where DocumentId in (110168791,
110132355,
110161904,
110171622,
110171627,
110171315)

can check PFP doc status by doc Ids
can get special Docusign document Id which used into TRIGGERS (column Id in this query)
if status is 'Sent' - doc is active and reminder will be sent according to Reminder Settings, 'Completed' - is signed




3. [docusign]

SELECT TOP (1000) [Id] ,[RemindAfter] ,[RemindEvery] ,[ExpireIn] ,[RemindBeforeExpiration] ,[DocumentId]
FROM [docusign].[dbo].[TRemindersAndExpirationSettings]
where DocumentId in (8888, 8890, 8892)

can check Reminder Settings for docusign documents
can calculate if the reminder still active (SentOn field from docusign + ExpireIn from reminder)



 4. [schedulerps]

SELECT TOP (1000) * FROM [schedulerps].[dbo].[PS_TRIGGERS] where TRIGGER_NAME like '%8892'
SELECT TOP (1000) * FROM [schedulerps].[dbo].[PS_SIMPLE_TRIGGERS] where TRIGGER_NAME like '%8892'

can check Triggers into scheduler by tempalete above
if there is not trigger for exact document - there is no notifications for this doc







User data

SELECT top 1000
c.CRMContactId, c.PersonId, c.LastName, c.FirstName, c.DOB, c.Postcode, c.OriginalAdviserCRMId, c.CurrentAdviserCRMId, c.CurrentAdviserName,
c.CRMContactType, c.IndClientId, c.InternalContactFG, c.RefServiceStatusId, c.MigrationRef, c.CreatedDate, c.ExternalReference, c.CampaignDataId,
c.AdditionalRef, c.AdviserAssignedByUserId, c._OwnerId, c.FeeModelId, c.ServiceStatusStartDate, c.ClientTypeId, c.IsHeadOfFamilyGroup, c.FamilyGroupCreationDate,
c.IsDeleted,
u.UserId, u.Identifier, u.RefUserTypeId, u.Guid, u.Password as [UserPassword], u.PasswordSalt as [UserPasswordSalt], u.SyncPassword, u.ExpirePasswordOn,
u.Email as [UserEmail], u.EmailConfirmed, u.Status, u.GroupId, u.Telephone, u.Reference,
u.CanLogCases,
a.AccountId, a.Subject, a.Username, a.Email as [AccountEmail], a.IsLoginAllowed, a.IsAccountVerified, a.Password as [AccountPassword], a.PasswordSalt as [AccountPasswordSalt],
a.PasswordAlgorithm, a.PasswordChanged, a.LastLogin, a.LastFailedLogin, a.LastLockedOutDate, a.Created, a.LastUpdated, a.SyncDate,
rut.RefUserTypeId, rut.Identifier, rut.Url, rut.ConcurrencyId
--c.PersonId, u.CRMContactId, u.UserId, a.AccountId, u.Email, u.groupId, c.PersonId, a.Username, rut.Identifier, u.Guid

FROM crm..TCrmContact c

JOIN [administration].[dbo].[TUser] u on u.CRMContactId = c.CRMContactId

JOIN Membership..TAccount a on a.Subject = u.Guid

JOIN [administration].[dbo].[TRefUserType] rut on rut.RefUserTypeId = u.RefUserTypeId

Where
u.UserId = 132790

--c.IndClientId = 685
--AND u.Email like 'mikestephens@doctors.org.uk'
--AND ExternalReference like '2341000-02528820'





