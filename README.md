# bluespiderMod

This Mod will copy the content of a blueprint into the Spidertron logistics slot. The mod is currently in alpha phase. In case of issues or proposals for improvements/extra features, post them in the discussions. 

How it works:
1. Place a blueprint in the Spidertron trunk. Currently only the first blueprint is picked-up ( still have to figure out if I can cycle throught the blueprints placed in the Trunk). The blueprints entities will be added to quantities already requested in the slots.
2. Issue following naming conventions:
   - The copy/addtion of the blueprint is only triggered if the blueprint's label starts with \_P\_
   - Include \_E\_ in the label in case you first want to clear the logistics slots
   - Include \_nx_\_ x is a multiplier to request x multiple of entities from the blueprint.
3. Apply the blueprint by moving the Spidertron using its remote control.
4. after treamtment the first underscore is removed to prevent further treatment.
