package alloyuse;

import edu.mit.csail.sdg.alloy4.*;
import edu.mit.csail.sdg.alloy4compiler.ast.Command;
import edu.mit.csail.sdg.alloy4compiler.ast.Module;
import edu.mit.csail.sdg.alloy4compiler.parser.CompUtil;
import edu.mit.csail.sdg.alloy4compiler.translator.A4Options;
import edu.mit.csail.sdg.alloy4compiler.translator.A4Solution;
import edu.mit.csail.sdg.alloy4compiler.translator.TranslateAlloyToKodkod;
import solver.Solver;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import org.apache.commons.cli.*;

/* Example command-line invocation:
       java -cp alloy4.2_2015-02-22.jar:korat/lib/commons-cli-1.0.jar:. alloyuse.GenerateAFKodkod --pathIn /home/.../alloy --alloyModel listAF.als --countModels --createKodkodProgram --pathOut /home/.../java/auto --kodkodProgram Test.java --absRels this/AbsFun,this/AbsFun.af
*/

public class GenerateAFKodKod {
    final static String PATH_IN = "p";
    final static String ALLOY_MODEL = "i";
    final static String COUNT_MODELS = "c";
    final static String CREATE_KODKOD_PROGRAM = "k";
    final static String PATH_OUT = "q";
    final static String KODKOD_PROGRAM = "o";
    final static String ABS_RELS = "r";

    /**Read in the command-line arguments**/
    private static CommandLine parseArgs(Options options, String[] args) {
        Option pathIn = new Option(PATH_IN, "pathIn", true, "input file path");
        pathIn.setRequired(true);
        options.addOption(pathIn);

        Option alloyModel = new Option(ALLOY_MODEL, "alloyModel", true, "input alloy model");
        alloyModel.setRequired(true);
        options.addOption(alloyModel);

        Option countModels = new Option(COUNT_MODELS, "countModels", false, "count models");
        countModels.setRequired(false);
        options.addOption(countModels);

        Option createKodkodProgram = new Option(CREATE_KODKOD_PROGRAM, "createKodkodProgram", false, "create Kodkod program");
        createKodkodProgram.setRequired(false);
        options.addOption(createKodkodProgram);

        Option pathOut = new Option(PATH_OUT, "pathOut", true, "output file path");
        pathOut.setRequired(false);
        options.addOption(pathOut);

        Option javaProgram = new Option(KODKOD_PROGRAM, "kodkodProgram", true, "output Kodkod program");
        javaProgram.setRequired(false);
        options.addOption(javaProgram);

        Option absRels = new Option(ABS_RELS, "absRels", true, "relations that model abstract domain");
        absRels.setRequired(false);
        options.addOption(absRels);

        CommandLineParser parser = new BasicParser();
        HelpFormatter formatter = new HelpFormatter();
        CommandLine cmd = null;
        try {
            cmd = parser.parse(options, args);
        } catch (ParseException e) {
            String msg = "";
            if (e instanceof MissingOptionException) {
                msg = "Missing required option(s): ";
            } else if (e instanceof UnrecognizedOptionException) {
                msg = "Unrecognized option(s): ";
            }
            System.err.println(msg + e.getMessage());
            formatter.printHelp("java alloyuse.GenerateAFKodkod ...", options);
            System.exit(1);
        }
        return cmd;
    }

    static String renameJavaClass(String code, String newfilename) {
        String newname = newfilename.substring(0, newfilename.indexOf(".java"));
        int index = code.indexOf("public final class Test {");
        String output = code.substring(0, index + 19);
        output = output + newname;
        output = output + code.substring(index + 23);
        return output;
    }

    public static void main(String[] args) throws Err, IOException {
        Options options = new Options();
        CommandLine cmd = parseArgs(options, args);

        String pathIn = cmd.getOptionValue(PATH_IN);
        String alloyModel = cmd.getOptionValue(ALLOY_MODEL);
        boolean countModels = cmd.hasOption(COUNT_MODELS);
        boolean createKodkodProgram = cmd.hasOption(CREATE_KODKOD_PROGRAM);
        if (!countModels) { // minimal functionality
            createKodkodProgram = true;
        }
        String pathOut = cmd.getOptionValue(PATH_OUT); // if null, output to console
        String kodkodProgram = cmd.getOptionValue(KODKOD_PROGRAM, "Test.java");
        if (!kodkodProgram.endsWith(".java")) {
            kodkodProgram = kodkodProgram + ".java";
        }
        String absRels = cmd.getOptionValue(ABS_RELS); // if null, use all relations

        long start = System.currentTimeMillis();
        System.out.println("ALLOY START TIME: " + start);

        String model = pathIn + ((pathIn.endsWith("/")) ? "" : "/") + alloyModel;

        // Parse+typecheck the model
        System.out.println("=========== Parsing+Typechecking " + model + " =============");
        A4Reporter rep = new A4Reporter();
        Module world = CompUtil.parseEverything_fromFile(rep, null, model);

        // Set options for how to execute the command
        A4Options a4options = new A4Options();
        a4options.solver = A4Options.SatSolver.SAT4J; //A4Options.SatSolver.CNF;//SAT4J;//MiniSatJNI;
        a4options.noOverflow = true;

        List<Command> commands = world.getAllCommands();
        Command command = commands.get(0); // expect exactly one command
        System.out.println("============ Command " + command + ": ============");
        A4Solution ans = TranslateAlloyToKodkod.execute_command(rep, world.getAllReachableSigs(), command, a4options);
       
        if (createKodkodProgram) {
            String java = edit(ans.debugExtractKInput(), absRels.split(","));
            if (!kodkodProgram.equals("Test.java")) {
                java = renameJavaClass(java, kodkodProgram);
            }
            if (pathOut == null) {
                System.out.println(java);
            } else {
                writeStringToFile(kodkodProgram, pathOut, java);
            }
        }
        if (countModels) {
            int count = 0;
            while (ans.satisfiable()) {
                count++;
                ans = ans.next();
            }
       
            System.out.println("MODEL COUNT: " + count);
            long stop = System.currentTimeMillis();
            System.out.println("ALLOY STOP TIME: " + stop);
            long time = stop - start;
            System.out.println("ALLOY TIME TAKEN: " + time);
        }
    }

    static String edit(String java, String[] rels) {
        StringBuilder sb = new StringBuilder();
        sb.append("import solver.Solver;\n");
        sb.append(java.substring(0, java.indexOf("solver.options().setFlatten(false)"))); // skip this [deprecated?]
        sb.append("solver.options().setSymmetryBreaking(20);\n");
        sb.append("solver.options().setSkolemDepth(0);\n");
        sb.append("System.out.println(\"Solving...\");\n");
        sb.append("System.out.flush();\n");
        String var = java.substring(java.indexOf("solver.solve(") + 13, java.lastIndexOf(","));
        if (rels.length > 0) {
            sb.append("String[] abs = new String[]{");
            for (int i = 0; i < rels.length; i++) {
                sb.append("\"" + rels[i] + "\"");
                if (i < rels.length - 1) {
                    sb.append(", ");
                }
            }
            sb.append("};\n");
            sb.append("solver.solveAll(" + var + ", bounds, abs);\n");
        } else {
            sb.append("solver.solveAll(" + var + ", bounds);\n");
        }
        sb.append("}}\n");
        return sb.toString();
    }

    static void writeStringToFile(String file, String path, String body) throws IOException {
        Path p = FileSystems.getDefault().getPath(path, file);
        System.out.println("WRITING FILE: " + p);
        Files.write(p, body.getBytes());
    }
}
