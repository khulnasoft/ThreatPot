# Generated by Django 3.2.14 on 2022-08-17 08:49

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("threatpot", "0003_statistics"),
    ]

    operations = [
        migrations.AlterField(
            model_name="ioc",
            name="id",
            field=models.BigAutoField(
                auto_created=True, primary_key=True, serialize=False, verbose_name="ID"
            ),
        ),
        migrations.AlterField(
            model_name="sensors",
            name="id",
            field=models.BigAutoField(
                auto_created=True, primary_key=True, serialize=False, verbose_name="ID"
            ),
        ),
        migrations.AlterField(
            model_name="statistics",
            name="id",
            field=models.BigAutoField(
                auto_created=True, primary_key=True, serialize=False, verbose_name="ID"
            ),
        ),
    ]
