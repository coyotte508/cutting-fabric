# Cutting Fabric

A flutter project to help uphosltery craftsmen to calculate the amount of fabric needed for their projects.

<details>
  <summary>Screenshot</summary>
<img src="https://github.com/coyotte508/cutting-fabric/assets/342922/ab116f85-7669-401d-9d0d-889381846ccd" height=600 />
</details>

## Running the project

To run the project, you need to have flutter installed. Then, you can run the following command:

```bash
flutter gen-l10n
flutter run
```

## Algorithm

We use the bottom-left heuristic in 10 000 randomized runs, for instant results.

The problem has additional constraints compared to the original strip packing problem, such as rotation & centering cuts on patterns.

### Research

Research that can improve the algorithm:

- https://cgi.csc.liv.ac.uk/~epa/surveyhtml.html
- https://en.wikipedia.org/wiki/Strip_packing_problem
- https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0245267
- https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0282598
- https://link.springer.com/article/10.1007/s10479-021-04226-6 - pdf at https://hal.science/hal-03103286/file/pvs.pdf
