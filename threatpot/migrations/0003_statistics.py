# Generated by Django 3.2.14 on 2022-08-09 14:10

import datetime

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("threatpot", "0002_ioc_cowrie"),
    ]

    operations = [
        migrations.CreateModel(
            name="Statistics",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("source", models.CharField(max_length=15)),
                (
                    "view",
                    models.CharField(
                        choices=[
                            ("feeds", "Feeds View"),
                            ("enrichment", "Enrichment View"),
                        ],
                        default="feeds",
                        max_length=32,
                    ),
                ),
                (
                    "request_date",
                    models.DateTimeField(default=datetime.datetime.utcnow),
                ),
            ],
        ),
    ]
