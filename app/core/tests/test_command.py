"""
Test custom Django management commands.
"""

from unittest.mock import patch
from psycopg2 import OperationalError as Psycopg2Error

from django.core.management import call_command
from django.test import SimpleTestCase
from django.core.management.base import BaseCommand


class CommandTests(SimpleTestCase):
    """Test commands."""

    def test_wait_for_db_ready(self):
        """Test waiting for database if database ready."""
        with patch.object(
            BaseCommand, 'check'
        ) as patched_check:
            patched_check.return_value = True

            call_command("wait_for_db")

            patched_check.assert_called_with(databases=['default'])

    def test_wait_for_db_delay(self):
        """Test waiting for database when getting OperationalError"""
        with patch('time.sleep') as patched_sleep:
            with patch.object(BaseCommand, 'check') as patched_check:
                patched_check.side_effect = [Psycopg2Error] * 2 + \
                [Psycopg2Error] * 3 + [True]

                call_command("wait_for_db")

                self.assertEqual(patched_check.call_count, 6)
                patched_check.assert_called_with(databases=['default'])
