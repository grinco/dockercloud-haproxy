import tempfile
import unittest

from haproxy.config import parse_extra_bind_settings, parse_extra_frontend_settings


class ParseExtraBindSettings(unittest.TestCase):
    def test_parse_extra_bind_settings(self):
        self.assertEqual({}, parse_extra_bind_settings(""))
        self.assertEqual({"80": "name http"}, parse_extra_bind_settings("80:name http"))
        self.assertEqual({"80": "name  http"}, parse_extra_bind_settings(" 80 : name  http  "))
        self.assertEqual({"80": "name http", "443": "accept-proxy"},
                         parse_extra_bind_settings(" 443:accept-proxy  , 80:name http "))
        self.assertEqual({"80": "name, http", "443": "accept,-proxy"},
                         parse_extra_bind_settings(" 443:accept\,-proxy, 80:name\, http "))


class ParseExtraFrontendSettings(unittest.TestCase):
    def test_parse_extra_frontend_settings(self):
        self.assertEqual({}, parse_extra_frontend_settings(""))
        self.assertEqual({}, parse_extra_frontend_settings({}))
        tf = tempfile.NamedTemporaryFile();
        tf.write("http-request add-header file_header value99")
        tf.flush()

        envvars = {"EXTRA_FRONTEND_SETTINGS_443": " http-request add-header header1 value1, http-request add-header header2 va\,lue2,"
                                                  "  http-request add-header header3 value3 ",
                   "EXTRA_FRONTEND_SETTINGS_FILE_443": tf.name,
                   "EXTRA_FRONTEND_SETTINGS_80": "http-request add-header header4",
                   "EXTRA_FRONTEND_SETTINGS_8080": "",
                   "EXTRA_FRONTEND_SETTINGS_ABC": "http-request add-header header5",
                   "EXTRA_FRONTEND_SETTINGS_": "http-request add-header header6"}
        settings = {"443": ["http-request add-header file_header value99", "http-request add-header header1 value1", "http-request add-header header2 va,lue2",
                            "http-request add-header header3 value3"],
                    "80": ["http-request add-header header4"],
                    "8080": [""]}
        self.assertEqual(settings, parse_extra_frontend_settings(envvars))
