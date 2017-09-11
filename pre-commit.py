#!/usr/bin/env python3

from subprocess import check_output
from sys import exit

from flake8.main import application, git
from isort import SortImports


def hook(lazy=False, strict=False):
    """Execute Flake8 on the files in git's index.

    Determine which files are about to be committed and run Flake8 over them
    to check for violations.

    NB: Nim updated from 1:3.2.1-1 to add a filter on python files…

    :param bool lazy:
        Find files not added to the index prior to committing. This is useful
        if you frequently use ``git commit -a`` for example. This defaults to
        False since it will otherwise include files not in the index.
    :param bool strict:
        If True, return the total number of errors/violations found by Flake8.
        This will cause the hook to fail.
    :returns:
        Total number of errors found during the run.
    :rtype:
        int
    """
    with git.make_temporary_directory() as tempdir:
        filepaths = []
        for filepath in git.copy_indexed_files_to(tempdir, lazy):
            if not filepath.endswith('.py'):
                with open(filepath) as f:
                    try:
                        if any(s not in f.readline().lower() for s in ('#', 'python')):
                            continue
                    except:
                        continue
            filepaths.append(filepath)
        if not filepaths:
            return 0
        app = application.Application()
        app.initialize(['.'])
        app.options.exclude = git.update_excludes(app.options.exclude, tempdir)
        app.run_checks(filepaths)

    app.report_errors()
    return app.result_count if strict else 0


for path in check_output(['git', 'status', '--porcelain']).decode('utf-8').split('\n'):
    path = path.strip().split()
    if not path:
        continue
    if path[0] in 'AMR':
        path = ' '.join(path[3 if path[0] == 'R' else 1:])
        if path.endswith('.py'):
            SortImports(path)
            # isort modifies the files…
            check_output(['git', 'update-index', '--add', path])
    elif path[0] != 'D':
        print(path)

exit(hook(strict=True, lazy=True))
