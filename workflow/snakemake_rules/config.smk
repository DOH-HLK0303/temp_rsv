"""
This part of the workflow deals with configuration.

OUTPUTS:

    results/run_config.yaml
"""
import sys
from pathlib import Path
import yaml

def main():
    dump_and_validate(
        "results/run_config.yaml",
        Path(workflow.basedir) / "config.schema.yaml"
    )
    write_subsample_config()


def write_subsample_config():
    for a_or_b in config["subtypes"]:
        for build_name in config["builds_to_run"]:
            for resolution in config["resolutions_to_run"]:
                build = f"{a_or_b}/{build_name}/{resolution}"
                if "custom_subsample" in config:
                    section = ["custom_subsample", build]
                else:
                    section = ["subsample", build]
                write_config(f"results/{build}/subsample2_config.yaml", section=section)

                # Make a copy without subsampling for the initial filter step
                with open(f"results/{build}/subsample2_config.yaml") as f:
                    initial_config = yaml.safe_load(f)
                for sample in initial_config["samples"].values():
                    for key in ("group_by", "max_sequences", "sequences_per_group"):
                        sample.pop(key, None)
                with open(f"results/{build}/initial_filter_config.yaml", "w") as f:
                    yaml.safe_dump(initial_config, f, sort_keys=False)

try:
    main()
except InvalidConfigError as e:
    print(f"ERROR: {e}", file=sys.stderr)
    exit(1)
