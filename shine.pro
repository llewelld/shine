TEMPLATE = subdirs
SUBDIRS += libhue plugin apps

plugin.depends = libhue
apps.depends = libhue plugin
