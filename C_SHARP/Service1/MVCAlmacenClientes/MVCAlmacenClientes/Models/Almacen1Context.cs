using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace MVCAlmacenClientes.Models;

public partial class Almacen1Context : DbContext
{
    public Almacen1Context()
    {
    }

    public Almacen1Context(DbContextOptions<Almacen1Context> options)
        : base(options)
    {
    }

    public virtual DbSet<Clientes1> Clientes1s { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=DESKTOP-T08FBE0\\SQLEXPRESS; Database=Almacen1; User Id=sa; Password=12345; MultipleActiveResultSets=False;Encrypt=False;TrustServerCertificate=False;Connection Timeout=30;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Clientes1>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("Clientes1");

            entity.Property(e => e.CliId)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("Cli_Id");
            entity.Property(e => e.CliNom)
                .HasMaxLength(80)
                .IsUnicode(false)
                .HasColumnName("Cli_Nom");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
