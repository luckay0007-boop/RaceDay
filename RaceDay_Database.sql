
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'RaceDay')
BEGIN
    CREATE DATABASE RaceDay;
END
GO

USE RaceDay;
GO

IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.UserRoles', 'U') IS NOT NULL DROP TABLE dbo.UserRoles;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO


CREATE TABLE dbo.Users (
    UserId          INT             IDENTITY(1,1)   NOT NULL,
    FirstName       NVARCHAR(100)                   NOT NULL,
    LastName        NVARCHAR(100)                   NOT NULL,
    Email           NVARCHAR(255)                   NOT NULL,
    PasswordHash    NVARCHAR(500)                   NOT NULL,
    DateOfBirth     DATE                            NULL,
    Gender          NVARCHAR(10)                    NULL,
    PhoneNumber     NVARCHAR(20)                    NULL,
    City            NVARCHAR(100)                   NULL,
    Province        NVARCHAR(100)                   NULL,
    CreatedAt       DATETIME2       DEFAULT GETDATE() NOT NULL,

    CONSTRAINT PK_Users PRIMARY KEY (UserId),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT CK_Users_Gender CHECK (Gender IN ('Male', 'Female', 'Other'))
);
GO

CREATE TABLE dbo.Roles (
    RoleId      INT             IDENTITY(1,1)   NOT NULL,
    RoleName    NVARCHAR(50)                    NOT NULL,

    CONSTRAINT PK_Roles PRIMARY KEY (RoleId),
    CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName)
);
GO


CREATE TABLE dbo.UserRoles (
    UserRoleId  INT             IDENTITY(1,1)   NOT NULL,
    UserId      INT                             NOT NULL,
    RoleId      INT                             NOT NULL,

    CONSTRAINT PK_UserRoles PRIMARY KEY (UserRoleId),
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId) ON DELETE CASCADE,
    CONSTRAINT UQ_UserRoles_UserRole UNIQUE (UserId, RoleId)
);
GO


CREATE TABLE dbo.Events (
    EventId         INT             IDENTITY(1,1)   NOT NULL,
    OrganiserId     INT                             NOT NULL,
    Name            NVARCHAR(200)                   NOT NULL,
    Description     NVARCHAR(MAX)                   NULL,
    EventDate       DATE                            NOT NULL,
    StartTime       TIME                            NOT NULL,
    Location        NVARCHAR(300)                   NOT NULL,
    City            NVARCHAR(100)                   NOT NULL,
    Province        NVARCHAR(100)                   NOT NULL,
    EventType       NVARCHAR(20)                    NOT NULL,
    Status          NVARCHAR(20)    DEFAULT 'Draft' NOT NULL,
    CreatedAt       DATETIME2       DEFAULT GETDATE() NOT NULL,
    UpdatedAt       DATETIME2       DEFAULT GETDATE() NOT NULL,

    CONSTRAINT PK_Events PRIMARY KEY (EventId),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_Events_EventType CHECK (EventType IN ('Running', 'Walking', 'Cycling')),
    CONSTRAINT CK_Events_Status CHECK (Status IN ('Draft', 'Published', 'Completed', 'Cancelled'))
);
GO


CREATE TABLE dbo.Categories (
    CategoryId      INT             IDENTITY(1,1)   NOT NULL,
    EventId         INT                             NOT NULL,
    Name            NVARCHAR(100)                   NOT NULL,
    Distance        DECIMAL(6,2)                    NOT NULL,
    MaxParticipants INT                             NULL,
    EntryFee        DECIMAL(10,2)   DEFAULT 0.00    NOT NULL,
    CreatedAt       DATETIME2       DEFAULT GETDATE() NOT NULL,

    CONSTRAINT PK_Categories PRIMARY KEY (CategoryId),
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId) REFERENCES dbo.Events(EventId) ON DELETE CASCADE,
    CONSTRAINT CK_Categories_Distance CHECK (Distance > 0),
    CONSTRAINT CK_Categories_EntryFee CHECK (EntryFee >= 0)
);
GO

CREATE TABLE dbo.Enrolments (
    EnrolmentId     INT             IDENTITY(1,1)   NOT NULL,
    ParticipantId   INT                             NOT NULL,
    CategoryId      INT                             NOT NULL,
    EnrolmentDate   DATETIME2       DEFAULT GETDATE() NOT NULL,
    BibNumber       NVARCHAR(20)                    NULL,
    Status          NVARCHAR(20)    DEFAULT 'Registered' NOT NULL,
    CreatedAt       DATETIME2       DEFAULT GETDATE() NOT NULL,

    CONSTRAINT PK_Enrolments PRIMARY KEY (EnrolmentId),
    CONSTRAINT FK_Enrolments_Participants FOREIGN KEY (ParticipantId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId) ON DELETE CASCADE,
    CONSTRAINT UQ_Enrolments_ParticipantCategory UNIQUE (ParticipantId, CategoryId),
    CONSTRAINT CK_Enrolments_Status CHECK (Status IN ('Registered', 'Confirmed', 'Withdrawn', 'DNS'))
);
GO


CREATE TABLE dbo.Results (
    ResultId        INT             IDENTITY(1,1)   NOT NULL,
    EnrolmentId     INT                             NOT NULL,
    FinishTime      TIME                            NULL,
    Position        INT                             NULL,
    Status          NVARCHAR(20)    DEFAULT 'Finished' NOT NULL,
    RecordedAt      DATETIME2       DEFAULT GETDATE() NOT NULL,

    CONSTRAINT PK_Results PRIMARY KEY (ResultId),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId) REFERENCES dbo.Enrolments(EnrolmentId) ON DELETE CASCADE,
    CONSTRAINT UQ_Results_Enrolment UNIQUE (EnrolmentId),
    CONSTRAINT CK_Results_Status CHECK (Status IN ('Finished', 'DNF', 'DSQ')),
    CONSTRAINT CK_Results_Position CHECK (Position IS NULL OR Position > 0)
);
GO

INSERT INTO dbo.Roles (RoleName) VALUES ('Organiser');
INSERT INTO dbo.Roles (RoleName) VALUES ('Participant');
GO



INSERT INTO dbo.Users (FirstName, LastName, Email, PasswordHash, DateOfBirth, Gender, PhoneNumber, City, Province)
VALUES ('Thandi', 'Nkosi', 'thandi.nkosi@raceday.co.za',
        '$2a$11$EXAMPLEHASH1234567890abcdefghijklmnopqrstuvwxyz012345',
        '1985-03-14', 'Female', '082-555-0101', 'Johannesburg', 'Gauteng');

INSERT INTO dbo.Users (FirstName, LastName, Email, PasswordHash, DateOfBirth, Gender, PhoneNumber, City, Province)
VALUES ('Johan', 'van der Merwe', 'johan.vdm@raceday.co.za',
        '$2a$11$EXAMPLEHASH1234567890abcdefghijklmnopqrstuvwxyz012346',
        '1978-11-22', 'Male', '083-555-0202', 'Cape Town', 'Western Cape');


INSERT INTO dbo.Users (FirstName, LastName, Email, PasswordHash, DateOfBirth, Gender, PhoneNumber, City, Province)
VALUES ('Sipho', 'Dlamini', 'sipho.dlamini@gmail.com',
        '$2a$11$EXAMPLEHASH1234567890abcdefghijklmnopqrstuvwxyz012347',
        '1992-07-08', 'Male', '071-555-0303', 'Durban', 'KwaZulu-Natal');

INSERT INTO dbo.Users (FirstName, LastName, Email, PasswordHash, DateOfBirth, Gender, PhoneNumber, City, Province)
VALUES ('Lerato', 'Mokoena', 'lerato.mokoena@outlook.com',
        '$2a$11$EXAMPLEHASH1234567890abcdefghijklmnopqrstuvwxyz012348',
        '1998-01-30', 'Female', '064-555-0404', 'Pretoria', 'Gauteng');
GO


INSERT INTO dbo.UserRoles (UserId, RoleId) VALUES (1, 1);
INSERT INTO dbo.UserRoles (UserId, RoleId) VALUES (2, 1);
INSERT INTO dbo.UserRoles (UserId, RoleId) VALUES (3, 2);
INSERT INTO dbo.UserRoles (UserId, RoleId) VALUES (4, 2);
GO

INSERT INTO dbo.Events (OrganiserId, Name, Description, EventDate, StartTime, Location, City, Province, EventType, Status)
VALUES (1, 'Soweto Marathon 2026',
        'The iconic Soweto Marathon returns for its 2026 edition! Experience the vibrant streets of Soweto on a fast, flat course perfect for personal bests. Water stations every 3km, live entertainment, and a post-race festival await.',
        '2026-11-01', '06:00:00',
        'FNB Stadium, Nasrec',
        'Johannesburg', 'Gauteng', 'Running', 'Published');

INSERT INTO dbo.Events (OrganiserId, Name, Description, EventDate, StartTime, Location, City, Province, EventType, Status)
VALUES (2, 'Cape Town Cycle Tour 2027',
        'The world''s largest individually timed cycle race. Ride the stunning 109km route around the Cape Peninsula, taking in Chapman''s Peak, the Atlantic coastline, and the iconic Table Mountain backdrop.',
        '2027-03-14', '06:30:00',
        'Grand Parade, Darling Street',
        'Cape Town', 'Western Cape', 'Cycling', 'Published');

INSERT INTO dbo.Events (OrganiserId, Name, Description, EventDate, StartTime, Location, City, Province, EventType, Status)
VALUES (1, 'Midlands Meander Charity Walk 2026',
        'A scenic charity walk through the beautiful KZN Midlands. All proceeds go to local community development projects. Fun for the whole family with 5km and 10km options.',
        '2026-12-06', '07:30:00',
        'Midlands Mall Parking Area',
        'Pietermaritzburg', 'KwaZulu-Natal', 'Walking', 'Draft');
GO


INSERT INTO dbo.Categories (EventId, Name, Distance, MaxParticipants, EntryFee)
VALUES (1, '42.2km Full Marathon', 42.20, 8000, 350.00);
INSERT INTO dbo.Categories (EventId, Name, Distance, MaxParticipants, EntryFee)
VALUES (1, '21.1km Half Marathon', 21.10, 12000, 250.00);
INSERT INTO dbo.Categories (EventId, Name, Distance, MaxParticipants, EntryFee)
VALUES (1, '10km Fun Run', 10.00, 5000, 150.00);

INSERT INTO dbo.Categories (EventId, Name, Distance, MaxParticipants, EntryFee)
VALUES (2, '109km Full Tour', 109.00, 35000, 650.00);
INSERT INTO dbo.Categories (EventId, Name, Distance, MaxParticipants, EntryFee)
VALUES (2, '47km Short Route', 47.00, 5000, 450.00);

INSERT INTO dbo.Categories (EventId, Name, Distance, MaxParticipants, EntryFee)
VALUES (3, '10km Walk', 10.00, 500, 100.00);
INSERT INTO dbo.Categories (EventId, Name, Distance, MaxParticipants, EntryFee)
VALUES (3, '5km Family Walk', 5.00, 300, 50.00);
GO


INSERT INTO dbo.Enrolments (ParticipantId, CategoryId, BibNumber, Status)
VALUES (3, 2, 'SM-4521', 'Confirmed');

INSERT INTO dbo.Enrolments (ParticipantId, CategoryId, BibNumber, Status)
VALUES (3, 4, 'CT-11234', 'Registered');

INSERT INTO dbo.Enrolments (ParticipantId, CategoryId, BibNumber, Status)
VALUES (4, 3, 'SM-7890', 'Confirmed');

INSERT INTO dbo.Enrolments (ParticipantId, CategoryId, BibNumber, Status)
VALUES (4, 7, 'MW-0055', 'Registered');

INSERT INTO dbo.Enrolments (ParticipantId, CategoryId, BibNumber, Status)
VALUES (3, 6, 'MW-0101', 'Registered');
GO


INSERT INTO dbo.Results (EnrolmentId, FinishTime, Position, Status)
VALUES (1, '01:45:32', 156, 'Finished');

INSERT INTO dbo.Results (EnrolmentId, FinishTime, Position, Status)
VALUES (3, '00:52:18', 412, 'Finished');
GO

PRINT '=== RaceDay Database Created Successfully ===';
PRINT '';

SELECT 'Users' AS TableName, COUNT(*) AS RecordCount FROM dbo.Users
UNION ALL
SELECT 'Roles', COUNT(*) FROM dbo.Roles
UNION ALL
SELECT 'UserRoles', COUNT(*) FROM dbo.UserRoles
UNION ALL
SELECT 'Events', COUNT(*) FROM dbo.Events
UNION ALL
SELECT 'Categories', COUNT(*) FROM dbo.Categories
UNION ALL
SELECT 'Enrolments', COUNT(*) FROM dbo.Enrolments
UNION ALL
SELECT 'Results', COUNT(*) FROM dbo.Results;
GO
