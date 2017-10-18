# General Purpose
Running code analysis with FixInsight against an input file (project or project group) and getting a single HTML report as an output.

# Features
- Single HTML report with customizable template.
- Single configuration file both for this application and FixInsight command-line parameters.
- Environment variables support.
- Supported input file types: _*.dpr, *.dpk, *.dproj, *.groupproj_
- [optional] Excluding projects by regex patterns. Useful for excluding third party libraries.
- [optional] Excluding units by regex patterns. Useful for excluding third party dependencies and generated files.
- [optional] Code analysis messages deduplication. Useful in case of units shared across several projects in group.
- [optional] Non-zero exit code when reaching specified threshold of code analysis messages count. Useful for failing CI builds.
- [optional] Code snippets with syntax highlight.
- [optional] Resulting report packaging in the archive.
- [optional] Automatic detection of the properly installed FixInsight.
- [optional] Logging & debug mode.

# Development

- Delphi XE8+
- Should compile with Starter Edition.
- Almost zero dependencies (only vendored).
- TestInsight is used for running tests. This can be bypassed via removing define `TESTINSIGHT` in the DUnit project.

# Testing

Tested with/on:
- FixInsight 2016.x / 2017.x
- Windows 7 / 8.1 / Server 2012
- TeamCity 8.1

# Trademark Legal Notice
All product names, logos, and brands are property of their respective owners.   
All company, product and service names used in the text above are for identification purposes only.
