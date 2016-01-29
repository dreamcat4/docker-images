
### Config.custom

Use this folder to put in your per-user custom configuration settings. Files placed in this folder override any pre-existing generic configurations in the `config.default` base folder.

Use this folder as a way to save and automatically restore your own private per-user configuration settings. It is not meant to re-distribute / upload the contents of this folder. They are in `.gitignore`.

During image build time, all files / folders from this folder are also copied (after `config.default`) into `/etc/config.preseed` inside the resultant image. So only images that you (re-)build yourself will include your custom configuration (and therefore should not be shared).

When a new runtime container is created from this image, the container itself will check for a pre-existing configuration files. If not present (first run) then the pre-seeded config will be used to populate the working `/config` folder. Which we recommend you bind-mount to `config.current/` subfolder alongside these ones. For easier diff / merge. Subsequent invokations with an existing and current config folder will not use again the pre-seeded data / overwrite your working config.


