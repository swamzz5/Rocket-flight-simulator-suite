# Rocket Design & Flight Simulation Suite

A modular MATLAB rocket flight simulator: 1D vertical ascent/descent dynamics,
ISA atmosphere, Mach-dependent drag, Barrowman stability analysis, and
propulsive ("suicide burn") landing recovery — with an automated test suite
and timestep/integrator validation studies.

Developed by Swayam Rout.

---

## Features

- **Flight dynamics**: semi-implicit (Euler-Cromer) integration of vertical
  ascent, coast, and descent, with an optional 4th-order Runge-Kutta (RK4)
  variant for comparison.
- **Atmosphere**: International Standard Atmosphere (troposphere +
  isothermal lower stratosphere), including density, pressure, temperature,
  speed of sound, and Sutherland-law viscosity.
- **Aerodynamics**: Mach-dependent drag coefficient (subsonic → transonic
  rise → supersonic), dynamic pressure (Max-Q) and Reynolds number tracked
  throughout flight.
- **Propulsion**: constant-thrust motor model with time-based mass
  depletion, mass-flow-consistent between ascent and landing burns.
- **Stability**: Barrowman center-of-pressure calculation (nose + fins),
  combined with a user-supplied center of gravity to report static margin
  in calibers and a STABLE/MARGINAL/UNSTABLE classification.
- **Recovery**: propulsive landing via an idealized suicide-burn guidance
  law — ignites at the kinematically correct moment, cuts thrust when
  velocity reaches zero, and reports landing outcome (soft landing vs.
  crash) and reserve fuel margin.
- **Validation**: an automated test suite (`tests/`) and dedicated
  timestep-convergence / integrator-comparison studies (`validation/`).
- **Automated reporting**: a Markdown mission report generator covering
  vehicle, environment, flight, propulsion, stability, and recovery.

---

## Architecture

```
RocketSimulation/
├── RocketFlightSimulator.m   entry point (interactive CLI)
├── config/                   simulation settings (dt, maxTime, g)
├── database/                 rocket definitions
├── atmosphere/                ISA atmosphere model
├── aerodynamics/              drag, Cd(Mach), Mach, Reynolds, dynamic pressure
├── propulsion/                thrust and mass-depletion models
├── dynamics/                  equations of motion (1D baseline)
├── simulation/                 integration loop(s) + runMission.m (callable core)
├── stability/                  Barrowman CP + static margin
├── recovery/                   suicide-burn ignition trigger
├── events/                     flight event detection (apogee, burnout, landing, ...)
├── plotting/                   time-history plots
├── reports/                    automated mission report generator
├── validation/                 convergence study, integrator comparison
├── tests/                      automated pass/fail test suite
└── documentation/              supplementary notes
```

The core design principle: `simulation/simulateFlight.m` is pure
orchestration (the loop, state storage, event triggers); the actual physics
(`dynamics/equationsOfMotion1D.m`, `aerodynamics/*`, `propulsion/*`) lives in
single-responsibility functions the loop calls. This is what makes it
possible to swap in `simulation/simulateFlightRK4.m` for comparison without
touching drag, mass, or thrust logic at all.

`simulation/runMission.m` is the **non-interactive, callable entry point** —
it runs a full mission (sim + stability) given a rocket/settings struct, with
no `input()` prompts. Tests, validation studies, and the report generator
all build on this, not on the interactive script.

---

## Governing Equations

| Model | Equation | Notes |
|---|---|---|
| Equations of motion | `m·V̇ = T − D − mg` | 1D vertical, point-mass |
| Drag | `D = ½ρV²·Cd·A` | Cd is Mach-dependent, piecewise-constant |
| Dynamic pressure | `q = ½ρV²` | tracked every timestep for Max-Q |
| Mach number | `M = V/a` | |
| Reynolds number | `Re = ρVL/μ` | |
| ISA troposphere | `T = T₀−Lh`, `P = P₀(T/T₀)^(g/RL)` | valid 0–11,000 m |
| ISA lower stratosphere | `P = P₁₁·exp(−g(h−11000)/RT)` | valid 11,000–20,000 m; extrapolated warning beyond |
| Barrowman CP (nose) | `Cn_α=2`, `Cp = k·L_nose` | k=0.466 (ogive), 0.666 (conical) |
| Barrowman CP (fins) | see `stability/barrowmanCP.m` header | subsonic, thin-fin theory |
| Static margin | `(Cp−Cg)/diameter` | in calibers |
| Suicide burn ignition | `altitude ≤ V²/(2·decel)` | idealized, instant on/off |

Full derivations, variable definitions, units, and assumptions are in each
function's header comment — these are treated as the primary documentation,
not duplicated in full here.

---

## Installation / Usage

1. Clone or download this folder.
2. Open MATLAB, `cd` into `RocketSimulation/`.
3. Run the interactive simulator:
   ```matlab
   RocketFlightSimulator
   ```
   Follow the prompts (rocket selection, launch altitude, etc.).
4. Run the automated test suite:
   ```matlab
   runAllTests()
   ```
5. Run a validation study:
   ```matlab
   rocketDB = rocketDatabase(); rocket = rocketDB(3);   % Sounding Rocket
   settings = simSettings();
   convergenceStudy(rocket, settings, 0);
   integratorComparison(rocket, settings, 0);
   ```
6. Run headlessly / generate a report programmatically:
   ```matlab
   mission = runMission(rocket, settings, 0);
   generateMissionReport(mission, 'my_report.md');
   ```

---

## Example Results (Sounding Rocket, sea-level launch)

| Metric | Value |
|---|---|
| Apogee | 4160.6 m |
| Max Velocity | 441.9 m/s |
| Max Mach | 1.32 |
| Max Acceleration | 156.2 m/s² (landing burn, not ascent) |
| Static Margin | 4.03 calibers (STABLE) |
| Impact Velocity (propulsive landing) | 1.10 m/s (SOFT LANDING) |
| Landing Fuel Used | 0.500 kg (of 0.500 kg reserved) |

These were independently cross-checked against a standalone Python
re-implementation of the same physics before being adopted as reference
values (see `tests/test_fullMission.m` for the automated version of this
kind of check).

---

## Validation

- **`tests/runAllTests.m`** — automated checks: ISA values against
  published reference data, drag/Reynolds/Mach against hand calculations,
  mass conservation during burn, Barrowman CP against an independently
  verified reference case, and full-mission physical invariants (mass
  never negative, fuel budget respected, etc.).
- **`validation/convergenceStudy.m`** — runs the same flight at
  `dt = 0.1, 0.01, 0.001 s` and reports how apogee/velocity/impact
  results converge as the timestep shrinks.
- **`validation/integratorComparison.m`** — runs the same flight through
  both the default Euler-Cromer integrator and an RK4 variant
  (`simulation/simulateFlightRK4.m`) at the same timestep, quantifying how
  much accuracy the simpler integrator gives up.

---

## Limitations

This project uses engineering approximations, not CFD, and is **not**
flight-certified. Specifically:

- **1D vertical flight only** — no horizontal drift, wind, launch angle,
  or attitude dynamics.
- **Drag coefficient** is a piecewise-constant function of Mach number,
  not a continuous or vehicle-specific aerodynamic model.
- **Barrowman stability** is a subsonic, small-angle-of-attack method — it
  does not capture the aft CP shift real rockets experience near Mach 1.
- **Suicide-burn landing guidance is idealized**: instant thrust on/off,
  no sensor/actuator lag, no safety margin. A real vehicle would ignite
  earlier to cover those uncertainties.
- **Rocket geometry** (nose/fin dimensions, center of gravity) for the
  built-in database entries are engineering *estimates*, not measured
  hardware data — replace them with real values before trusting stability
  or landing results for a specific vehicle.
- **ISA atmosphere** is validated for 0–20,000 m; `isaAtmosphere.m` issues
  a warning (not silent extrapolation) above that range.
- Two of the three database rockets are modeled as small **solid-motor**
  vehicles for testing convenience — real solid motors cannot relight or
  throttle, so their propulsive-landing numbers are not physically
  achievable with that motor type, only numerically exercisable.

---

## Future Work

- 2D/3D flight dynamics (horizontal drift, wind, launch angle)
- Real thrust-curve interpolation (replacing the constant-thrust step
  function)
- Throttleable landing engine with a continuous guidance law, instead of
  the current idealized instant on/off suicide burn
- Parachute-based recovery as an alternative to propulsive landing
- PDF mission reports (currently Markdown)
