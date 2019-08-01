package solver;

import kodkod.ast.Formula;
import kodkod.ast.Relation;
import kodkod.engine.config.Options;
import kodkod.engine.fol2sat.Translation;
import kodkod.engine.fol2sat.Translator;
import kodkod.engine.satlab.SATSolver;
import kodkod.instance.Bounds;
import kodkod.util.ints.IntSet;
import kodkod.util.ints.IntTreeSet;

import java.util.*;

public class Solver { // borrowed from Torlak's Kodkod codebase
    private Bounds bounds;
    private SATSolver cnf;
    private Translation.Whole transl;
    private int primaryVars;
    private Options options = new Options();

    /**Toggle this value if you want to be able to view the generated solutions**/
    final static boolean PRINT_SOLUTIONS = false;

    public Options options() {
        return options;
    }

    public void solveAll() {
        solveAll(bounds.relations());
    }

    private Set<Relation> nameToRelation(String[] rels) {
        Map<String, Relation> name2rel = new HashMap<>();
        for (Relation rel: bounds.relations()) {
            if (name2rel.put(rel.name(), rel) != null) {
                throw new IllegalArgumentException("Name conflict");
            }
        }
        Set<Relation> result = new HashSet<>();
        for (String r: rels) {
            result.add(name2rel.get(r));
        }
        return result;
    }

    private void commonInit(Formula formula, Bounds bounds) {
        this.bounds = bounds;
        long translTime = System.currentTimeMillis();
        transl = Translator.translate(formula, bounds, options);
        translTime = System.currentTimeMillis() - translTime;
        System.out.println("Translation time: " + translTime + "\n");
        cnf = transl.cnf();
        if (transl.trivial()) throw new RuntimeException("Unable to handle trivial formulas");
        primaryVars = transl.numPrimaryVariables();
        System.out.println("SIZE OF ALLOY MODEL: ");
        System.out.println("   VARIABLES: " + cnf.numberOfVariables());
        System.out.println("   PRIMARY VARS: " + primaryVars);
        System.out.println("   CLAUSES: " + cnf.numberOfClauses());
    }

    public void solveAll(Formula formula, Bounds bounds) {
        commonInit(formula, bounds);
        solveAll(bounds.relations());
    }

    public void solveAll(Formula formula, Bounds bounds, Set<Relation> abstractionFunctionState) {
        commonInit(formula, bounds);
        solveAll(abstractionFunctionState);
    }

    public void solveAll(Formula formula, Bounds bounds, String[] abstractionFunctionState) {
        commonInit(formula, bounds);
        solveAll(nameToRelation(abstractionFunctionState));
    }

    private void solveAll(Set<Relation> abstractionFunctionState) {
        IntSet absVars = new IntTreeSet();
        for (Relation rel: abstractionFunctionState) {
            absVars.addAll(transl.primaryVariables(rel));
        }
      
        int count = 0;
        long totalSolveTime = System.currentTimeMillis();
        while (true) {
            long solveTime = System.currentTimeMillis();
            final boolean isSat = cnf.solve();
            solveTime = System.currentTimeMillis() - solveTime;
            if (isSat) {
                count++;
                if (PRINT_SOLUTIONS) {
                    System.out.println("Instance: " + transl.interpret());
                    System.out.println();
                    System.out.println("Solving time: " + solveTime + "\n");
                }
                // add the negation of the current model w.r.t. absVars to the solver
                final int[] notModelAbsVars = new int[absVars.size()];
                int j = 0;
                for (int i = 1; i <= primaryVars; i++) {
                    if (absVars.contains(i)) {
                        notModelAbsVars[j] = cnf.valueOf(i) ? -i : i;
                        j++;
                    }
                }
                if (j != notModelAbsVars.length) throw new RuntimeException("Something's wrong");
                cnf.addClause(notModelAbsVars);
            } else {
                if (PRINT_SOLUTIONS) {
                    System.out.println("UNSAT");
                    System.out.println("Solving time: " + solveTime + "\n");
                }
                cnf.free();
                
                break;
            }
        }
        totalSolveTime = System.currentTimeMillis() - totalSolveTime;
        System.out.println("MODEL COUNT: " + count);
        System.out.println("TOTAL SOLVING TIME: " + totalSolveTime);
    }

    private String primaryVarsForAllRelations(Bounds bounds) {
        StringBuilder sb = new StringBuilder();
        for (Relation rel: bounds.relations()) {
            sb.append(rel + "=" + transl.primaryVariables(rel) + " ");
        }
        return sb.toString();
    }

    private String booleanSolution(SATSolver solver, int primaryVars) {
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= primaryVars; i++) {
            sb.append(solver.valueOf(i) ? "1" : "0");
        }
        return sb.toString();
    }
}
