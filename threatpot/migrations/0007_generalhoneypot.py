# Generated by Django 3.2.16 on 2023-01-20 11:10

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("threatpot", "0006_ioc_general_hps"),
    ]

    operations = [
        migrations.CreateModel(
            name="GeneralHoneypot",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("name", models.CharField(max_length=15)),
                ("active", models.BooleanField(default=True)),
            ],
        ),
    ]
