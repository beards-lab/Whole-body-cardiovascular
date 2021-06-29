# About
Model of cardiovascular model is able to describe  supine normal, tilt, valsalva maneuver and exercise of a healthy subject.

# Required

Implemented in Modelica language. Requires:

- [Modelica Standard library 4.0](https://github.com/modelica/ModelicaStandardLibrary/releases/tag/v4.0.0) (Usually already a part of the Modelica environment)
- [Physiolibrary 2.5.0](https://github.com/filip-jezek/Physiolibrary/releases/tag/v2.5)

Developed in Dymola 2021, tested in OpenModelica 1.17.

# Installation
- Install a Modelica tool, e.g. a latest version of the [OpenModelica](https://www.openmodelica.org/) (tested in [v1.17](https://build.openmodelica.org/omc/builds/windows/releases/1.17/0/64bit/) )
  - The MSL (Modelica Standard Library) 4.0 should be already loaded or load it manually
  - Current version is **NOT compatible with MSL 3.2.3**!!
- Download Physiolibrary from https://github.com/filip-jezek/Physiolibrary/releases/tag/v2.5
- Load the Physiolibrary into the Modelica tool
- Load the ADAN-86.mo model into the Modelica tool
  - If MSL 3.2.3 is loaded, the Modelica tool (e.g. Dymola) should provide a warning. Then get a MSL 4.0 instead from e.g. https://github.com/modelica/ModelicaStandardLibrary/releases/tag/v4.0.0
  
# Model Simulation
To simulate the following main use-cases, run:
- Supine baseline - ADAN_main.SystemicTree.Baseline.CVS_baseline
- Valsalva maneuver - ADAN_main.SystemicTree.Valsalva.CVS_valsalva
- 60° HUT - ADAN_main.SystemicTree.Tilt.CVS_tiltable
- Exercise (90% of maximal) - ADAN_main.SystemicTree.Exercise.CVS_exercise
- Exercise (Stepping from 0 -- 100%) - ADAN_main.SystemicTree.Exercise.CVS_Exercise_stepping
- Base model for extensions - ADAN_main.SystemicTree.CardiovascularSystem

In OpenModelica, make sure the CVODE algorithm is used. Model seems unstable using other integrators. New to OpenModelica? See out [OpenModelica quick-start guide](Doc/OpenModelica.md)

