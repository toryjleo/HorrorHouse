This documents the items required for an interact box witht the examine system.

There is an ExaminableItem.cs script that has some cool features. It acts as the root of the amaxinaable item and can even exist on an emptuy obsect that is not part of the model. If this is the case, make sure to enable 'empty parent' on the component
ExaminableItem.cs references a list of inspect points. Inspect points are empty gameobjects with an ExamineInspectPint.cs component. ExamineInspectPint.cs has a special interaction event hook and has a text description of the point. An object that has an ExamineInspectPint.cs component must be on the InspectPoint layer.
There is an InspectReveal script that, when called, will hide an object and show another.