# Installation

    pipenv install
    pipenv shell

# Syncing Productboard features into gitlab

This will create a gitlab issue for each user story in the specified sprint in productboard.

If the user story already has a link to a gitlab issue in the 'Gitlab' field, it will be ignored

After creating the issue in gitlab, it will backfill the 'Gitlab' field in productboard for crosslinking.

It will also create the milestone in gitlab if it doesn't exist yet as a group milestone. All issues are linked to this milestone

    ./productboard.py gitlab sync --username '$PB_USERNAME' --password '$PB_PASSWORD' --token '$GL_TOKEN' --release "$SPRINT"

