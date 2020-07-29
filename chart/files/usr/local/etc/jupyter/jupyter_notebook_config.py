c.ServerProxy.servers = {
  'we-nipreps-esteban': {
    'command': ['python3', '-m', 'http.server', '--directory', '/home/jovyan/data/openneuro/ds000114/derivatives/fmriprep-20.2.0rc0/fmriprep/', '{port}'],
  },
  'we-nilearn-dupre': {
    'command': ['python3', '-m', 'http.server', '--directory', '/nh/curriculum/we-nilearn-dupre/book', '{port}'],
  }
}
