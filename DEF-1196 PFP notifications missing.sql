Email text
Hi Laurie    As discussed, please find attached various documents relating to the proposed pension contribution.    Most importantly, please see the payment instructions which give Novia’s bank details for the payment. Please quote your Novia investor number, 219844 on the payment.    Please keep the Key Features Illustration for your records. This illustration also details the recommended investments and all associated charges, including the Initial Advice Charge of £380 which is to cover our costs in providing and implementing this advice. This is equivalent of 1.9% and falls within the remit of your agreed Service Charter.    I can confirm that I am recommending the same investment portfolio as that being used in your Novia ISA.    In due course please could you complete and sign the Novia Nomination/Expression of Wish form and sign and return the Novia SIPP application summary. These can be returned electronically if easier.    Whilst writing, I can confirm that we are processing your GIA to ISA transfer today further to your earlier message to proceed with this advice.    Please do come back to me to clarify or ask anything on these matters.    Kind regards    Frank  

--get secure messages from to
SELECT *
FROM [securemessage].[dbo].[TSecureMessage] m
join [securemessage].[dbo].[TSecureMessageRecipient] r on m.SecureMessageId = r.SecureMessageId
join [CRM].[dbo].[TContact] c ON m.SenderPartyId = c.CRMContactId

where
TenantId = 752
and SenderPartyId = 12654941
and PartyId = 25562990
and c.RefContactType = 'E-Mail'
order by m.[SecureMessageId]

--get Client claims
select * from
[Membership].[dbo].[TClaim]
where AccountId = 304924

--get account and email info by email
declare @Email VARCHAR(30) = 'lawrencebyrne@virginmedia.com'

SELECT *
FROM [Membership].[dbo].[TAccount]
where Email like @Email

SELECT *
FROM [email].[dbo].[TEmailRecipient]
where EmailAddress like @Email

SELECT *
  FROM [email].[dbo].[TEmailDelivery]
  where Recipients like @Email

SELECT *
  FROM [email].[dbo].[TEmailSent]
  where Destination like @Email

--get Adviser's Account and claims
SELECT *
FROM [Membership].[dbo].[TAccount]
where Email like 'frank.harewood@avtrinity.com'

select * from
[Membership].[dbo].[TClaim]
where AccountId = 12364

--get Clieny and Adviser user's data
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
c.IndClientId = 752
and
(
c.CRMContactId = 25562990
or c.CRMContactId = 12654941)
