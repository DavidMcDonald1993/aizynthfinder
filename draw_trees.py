import os, json

import pandas as pd

from aizynthfinder.reactiontree import ReactionTree

if __name__ == "__main__":

    output_filename = "my_output_dir/output.json"

    with open(output_filename, "r") as f:
        output = json.load(f)

    image_output_dir = "image_output_dir"
    os.makedirs(image_output_dir, exist_ok=True)


    trees = output["trees"]
    for molecule_id, tree in enumerate(trees):
        molecule_output_dir = os.path.join(
            image_output_dir,
            f"molecule_{molecule_id}"
        )
        os.makedirs(molecule_output_dir, exist_ok=True)

        for route_num, route in enumerate(tree):

            image_filename = os.path.join(molecule_output_dir, f"route{route_num:03d}.png")

            ReactionTree.from_dict(route).to_image().save(image_filename)




