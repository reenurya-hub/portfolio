USE [Bar]
GO

/****** Object:  Table [dbo].[Beer]    Script Date: 5/06/2023 9:30:08 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Beer](
	[BeerId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Style] [varchar](50) NULL
) ON [PRIMARY]
GO

