import Foundation
//import GameplayKit

//let mt = GKMersenneTwisterRandomSource.init(seed: 12345)

//for _ in (1...5) {
//  print(mt.nextUniform())
//}
// Placeholder under I get random numbers working
class Random {
              
}

class MazeCell: Hashable {
    var whatsHere : String = "" // One of "", "Potion", "Spellbook", and "Wand"

    var north : MazeCell?
    var south : MazeCell?
    var east : MazeCell?
    var west : MazeCell?
  
      static func == (lhs: MazeCell, rhs: MazeCell) -> Bool {
        return lhs.whatsHere == rhs.whatsHere && 
               lhs.north === rhs.north &&
              lhs.south === rhs.south &&
              lhs.east === rhs.east &&
              lhs.west === rhs.west
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(whatsHere)
        hasher.combine(north)
        hasher.combine(south)
        hasher.combine(east)
        hasher.combine(west)
    }

}

struct MazeUtilities {
  private init() { }

      /**
     * Given a location in a maze, returns whether the given sequence of
     * steps will let you escape the maze. The steps should be given as
     * a string made from N, S, E, and W for north/south/east/west without
     * spaces or other punctuation symbols, such as "WESNNNS"
     * <p>
     * To escape the maze, you need to find the Potion, the Spellbook, and
     * the Wand. You can only take steps in the four cardinal directions,
     * and you can't move in directions that don't exist in the maze.
     * <p>
     * It's assumed that the input MazeCell is not null.
     *
     * @param start The start location in the maze.
     * @param moves The sequence of moves.
     * @return Whether that sequence of moves picks up the needed items
     *         without making nay illegal moves.
     */
  static func isPathToFreedom(_ start : MazeCell?, _ moves : String) -> Bool {
        var curr = start
        var items = Set<String>()
        
        /* Fencepost issue: pick up items from starting location, if any. */
        if (start!.whatsHere != "") {
           items.insert(start!.whatsHere)
        }
        
        for ch in Array(moves) {
            /* Take a step. */
            if      (ch == "N") { curr = curr!.north! }
            else if (ch == "S") { curr = curr!.south! }
            else if (ch == "E") { curr = curr!.east! }
            else if (ch == "W") { curr = curr!.west! }
            else { return false } // Unknown character?
            
            /* Was that illegal? */
            if (curr == nil) { return false }
            
            /* Did we get anything? */
            if (curr!.whatsHere != "") {
               items.insert(curr!.whatsHere)
            }
        }
        
        /* Do we have all three items? */
        return items.count == 3
    }

    /* Simple rolling hash. Stolen shameless from StanfordCPPLib, maintained by a collection
     * of talented folks at Stanford University. We use this hash implementation to ensure
     * consistency from run to run and across systems.
     */
    private static let HASH_SEED = 5381;       // Starting point for first cycle
    private static let HASH_MULTIPLIER = 33;   // Multiplier for each cycle
    private static let HASH_MASK = 0x7FFFFFFF; // All 1 bits except the sign

      private static func hashCode(_ value : Int) -> Int {
        return value & HASH_MASK;
    }

    private static func hashCode(_ str : String) -> Int {
        var hash = HASH_SEED
        for ch in Array(str) {
            hash = HASH_MULTIPLIER * hash + Int(ch.asciiValue!);
        }
        return hashCode(hash);
    }

      /*
     * Computes a composite hash code from a list of multiple values.
     * The components are scaled up so as to spread out the range of values
     * and reduce collisions.
     */
    private static func hashCode(_ str : String, _ values : Int...) -> Int {
        var result = hashCode(str)
        for value in values {
            result = result * HASH_MULTIPLIER + value
        }
        return hashCode(result)
    }

      /* Size of a normal maze. */
    private static let NUM_ROWS = 4;
    private static let NUM_COLS = 4;
    
    /* Size of a twisty maze. */
    private static let TWISTY_MAZE_SIZE = 12;

        /**
     * Returns a maze specifically tailored to the given name.
     *
     * We've implemented this function for you. You don't need to write it
     * yourself.
     *
     * Please don't make any changes to this function - we'll be using our
     * reference version when testing your code, and it would be a shame if
     * the maze you solved wasn't the maze we wanted you to solve!
     */
    
    public static func mazeFor(_ name : String) -> MazeCell {
        //Random generator = new Random(hashCode(name, NUM_ROWS, NUM_COLS));
        let generator = Random()
        var maze = makeMaze(NUM_ROWS, NUM_COLS, generator);
        
        var linearMaze = [MazeCell]()
        for row in 0..<maze.count {
            for col in 0..<maze[0].count {
                linearMaze.append(maze[row][col]);
            }
        }
        
        let distances = allPairsShortestPaths(linearMaze);
        var locations = remoteLocationsIn(distances);
        
        // Place the items. 
        linearMaze[locations[1]].whatsHere = "Spellbook";
        linearMaze[locations[2]].whatsHere = "Potion";
        linearMaze[locations[3]].whatsHere = "Wand";

        // We begin in position 0. 
        return linearMaze[locations[0]];
    }
    

    /**
     * Returns a twisty maze specifically tailored to the given name.
     *
     * Please don't make any changes to this function - we'll be using our
     * reference version when testing your code, and it would be a shame if
     * the maze you solved wasn't the maze we wanted you to solve!
     */
    public static func twistyMazeFor(_ name : String) -> MazeCell {
        /* Java Random is guaranteed to produce the same sequence of values across
         * all systems with the same seed.
         */
        //Random generator = new Random(hashCode(name, TWISTY_MAZE_SIZE));
        let generator = Random()
        var maze = makeTwistyMaze(TWISTY_MAZE_SIZE, generator);

        /* Find the distances between all pairs of nodes. */
        let distances = allPairsShortestPaths(maze);

        /* Select a 4-tuple maximizing the minimum distances between points,
         * and use that as our item/start locations.
         */
        var locations = remoteLocationsIn(distances);

        /* Place the items there. */
        maze[locations[1]].whatsHere = "Spellbook";
        maze[locations[2]].whatsHere = "Potion";
        maze[locations[3]].whatsHere = "Wand";

        return maze[locations[0]];
    }

  
      /* Returns if two nodes are adjacent. */
    private static func areAdjacent(_ first: MazeCell?, _ second: MazeCell?) -> Bool{
        return first!.east  === second ||
               first!.west  === second ||
               first!.north === second ||
               first!.south === second
    }
  
      /* Uses the Floyd-Warshall algorithm to compute the shortest paths between all
     * pairs of nodes in the maze. The result is a table where table[i][j] is the
     * shortest path distance between maze[i] and maze[j].
     */
    private static func allPairsShortestPaths(_ maze : [MazeCell?]) -> [[Int]] {
        /* Floyd-Warshall algorithm. Fill the grid with "infinity" values. */
        var result = Array(repeating: Array(repeating: 0, count: maze.count), count: maze.count)
        for i in 0..<result.count {
            for j in 0..<result[i].count {
                result[i][j] = maze.count + 1
            }
        }

        /* Set distances of nodes to themselves at 0. */
        for i in 0..<maze.count {
            result[i][i] = 0
        }

        /* Set distances of edges to 1. */
        for i in 0..<maze.count {
            for j in 0..<maze.count {
                if (areAdjacent(maze[i], maze[j])) {
                    result[i][j] = 1;
                }
            }
        }

        /* Dynamic programming step. Keep expanding paths by allowing for paths
         * between nodes.
         */
        for i in 0..<maze.count {
            var next = Array(repeating: Array(repeating: 0, count: maze.count), count: maze.count)
            for j in 0..<maze.count {
                for k in 0..<maze.count {
                    next[j][k] = min(result[j][k], result[j][i] + result[i][k])
                }
            }
            result = next
        }

        return result
    }

      /* Given a list of distinct nodes, returns the "score" for their distances,
     * which is a sequence of numbers representing pairwise distances in sorted
     * order.
     */
    private static func  scoreOf(_ nodes: [Int], _ distances: [[Int]]) -> [Int] {
        var result = [Int]();

        for i in 0..<nodes.count {
            for j in (i + 1)..<nodes.count {
                result.append(distances[nodes[i]][nodes[j]]);
            }
        }

        return result.sorted();
    }

    /* Lexicographical comparison of two arrays; they're assumed to have the same length. */
    private static func lexicographicallyFollows(_ lhs : [Int], _ rhs : [Int]) -> Bool {
        for i in 0..<lhs.count {
            if (lhs[i] != rhs[i]) { return lhs[i] > rhs[i] }
        }
        return false;
    }

    /* Given a grid, returns a combination of four nodes whose overall score
     * (sorted list of pairwise distances) is as large as possible in a
     * lexicographical sense.
     */
    private static func remoteLocationsIn(_ distances : [[Int]] ) -> [Int] {
        var result = [0, 1, 2, 3]

        /* We could do this recursively, but since it's "only" four loops
         * we'll just do that instead. :-)
         */
        for i in 0..<distances.count {
            for j in (i + 1)..<distances.count {
                for k in (j + 1)..<distances.count {
                    for l in (k + 1)..<distances.count {
                        let curr = [i, j, k, l]
                        if (lexicographicallyFollows(scoreOf(curr, distances), scoreOf(result, distances))) {
                            result = curr;
                        }
                    }
                }
            }
        }

        return result;
    }

      /* Clears all the links between the given group of nodes. */
    private static func clearGraph(_ nodes : inout [MazeCell]) {
        for node in nodes {
            node.whatsHere = ""
            node.north = nil
            node.south = nil
            node.east = nil
            node.west = nil
        }
    }
    
    /* Enumerated type representing one of the four ports leaving a MazeCell. */
    private enum Port {
        case NORTH
        case SOUTH
        case EAST
        case WEST
    }

        /* Returns a random unassigned link from the given node, or nullptr if
     * they are all assigned.
     */
  
    private static func randomFreePortOf(_ cell : MazeCell, _ generator: Random) -> Port? {
        var ports = [Port]()
        if (cell.east  == nil) { ports.append(Port.EAST) }
        if (cell.west  == nil) { ports.append(Port.WEST) }
        if (cell.north == nil) { ports.append(Port.NORTH) }
        if (cell.south == nil) { ports.append(Port.SOUTH) }
        if (ports.count == 0) { return nil }

        //let port = generator.nextInt(ports.count);
        let port = Int.random(in: 0..<ports.count)
        return ports[port];
    }

      /* Links one MazeCell to the next using the specified port. */
    private static func link(_ from : MazeCell, _ to : MazeCell, _ link : Port) {
        switch (link) {
            case Port.EAST:
                from.east = to
            case Port.WEST:
                from.west = to
            case Port.NORTH:
                from.north = to
            case Port.SOUTH:
                from.south = to
        }
    }

    /* Use a variation of the Erdos-Renyi random graph model. We set the
     * probability of any pair of nodes being connected to be ln(n) / n,
     * then artificially constrain the graph so that no node has degree
     * four or more. We generate mazes this way until we find one that's
     * conencted.
     */
    private static func erdosRenyiLink(_ nodes : [MazeCell], _ generator : Random) -> Bool {
        /* High probability that everything is connected. */
        let threshold = log(Double(nodes.count)) / Double(nodes.count);

        for i in 0..<nodes.count {
            for j in (i + 1)..<nodes.count {
              // OLD IF
//                if (generator.nextDouble() <= threshold) {
                  if Double.random(in: 0.0..<1.0) <= threshold {
                    let iLink = randomFreePortOf(nodes[i], generator)
                    let jLink = randomFreePortOf(nodes[j], generator)

                    /* Oops, no free links. */
                    if (iLink == nil || jLink == nil) {
                        return false;
                    }
                    
                    link(nodes[i], nodes[j], iLink!);
                    link(nodes[j], nodes[i], jLink!);
                }
            }
        }

        return true;
    }

  struct Queue{
    var items : [MazeCell] = []
    mutating func enqueue(_ element: MazeCell) {
        items.append(element)
    }
    
    mutating func dequeue() -> MazeCell? {
        if items.isEmpty {
            return nil
        }
        else {
            let tempElement = items.first
            items.remove(at: 0)
            return tempElement
        }
    }
    func isEmpty() -> Bool {
        return items.isEmpty
    }
  }

      /* Returns whether the given maze is connected. Uses a BFS. */
    private static func isConnected(_ maze : [MazeCell]) -> Bool {
        var visited = Set<MazeCell>()
        var frontier = Queue()
        
        frontier.enqueue(maze[0]);

        while (!frontier.isEmpty()) {
            let curr = frontier.dequeue();

            if (curr != nil && !visited.contains(curr!)) {
                visited.insert(curr!);

                if let next = curr?.east { frontier.enqueue(next) }
                if let next = curr?.west { frontier.enqueue(next) }
                if let next = curr?.north { frontier.enqueue(next) }
                if let next = curr?.south { frontier.enqueue(next) }
            }
        }

        return visited.count == maze.count;
    }

    /* Generates a random twisty maze. This works by repeatedly generating
     * random graphs until a connected one is found.
     */
    private static func makeTwistyMaze(_ numNodes : Int, _ generator : Random) -> [MazeCell] {
        var result = [MazeCell]()
        for _ in 0..<numNodes {
            result.append(MazeCell());
        }

        /* Keep generating mazes until we get a connected one. */
        repeat {
            clearGraph(&result);
        } while (!erdosRenyiLink(result, generator) || !isConnected(result));

        return result;
    }

  
    /* Type representing an edge between two maze cells. */
    private final class EdgeBuilder {
        var from : MazeCell
        var to : MazeCell
        
        var fromPort : Port
        var toPort : Port
        
        init(_ from: MazeCell, _ to: MazeCell, _ fromPort: Port, _ toPort: Port) {
            self.from     = from;
            self.to       = to;
            self.fromPort = fromPort;
            self.toPort   = toPort;
        }
    }

        /* Returns all possible edges that could appear in a grid maze. */
    private static func allPossibleEdgesFor(_ maze : [[MazeCell]]) -> [EdgeBuilder]  {
        var result = [EdgeBuilder]()
        for row in 0..<maze.count {
            for col in 0..<maze[row].count {
                if (row + 1 < maze.count) {
                    result.append(EdgeBuilder(maze[row][col], maze[row + 1][col], Port.SOUTH, Port.NORTH));
                }
                if (col + 1 < maze[row].count) {
                    result.append(EdgeBuilder(maze[row][col], maze[row][col + 1], Port.EAST,  Port.WEST));
                }
            }
        }
        return result;
    }

    /* Union-find FIND operation. */
    private static func repFor(_ reps : [MazeCell: MazeCell], _ incomingCell : MazeCell) -> MazeCell {
        var cell = incomingCell
        while (reps[cell]! != cell) {
            cell = reps[cell]!
        }
        return cell
    }

    /* Shuffles the edges using the Fischer-Yates shuffle. */
    private static func shuffleEdges(_ edges : inout [EdgeBuilder], _ generator : Random) {
        for i in 0..<edges.count {
//            int j = generator.nextInt(edges.size() - i) + i;
          let j = Int.random(in: 0..<edges.count - i) + i
            
            let temp = edges[i]
            edges[i] = edges[j]
            edges[j] = temp
        }
    }

  
    /* Creates a random maze of the given size using a randomized Kruskal's
     * algorithm. Edges are shuffled and added back in one at a time, provided
     * that each insertion links two disconnected regions.
     */
    private static func makeMaze(_ numRows : Int, _ numCols : Int, _ generator : Random) -> [[MazeCell]] {
        var maze = Array(repeating: Array(repeating: MazeCell(), count: numCols), count: numRows)

        for row in 0..<numRows {
            for col in 0..<numCols {
                maze[row][col] = MazeCell()
            }
        }

        var edges = allPossibleEdgesFor(maze);
        shuffleEdges(&edges, generator);

        /* Union-find structure, done without path compression because N is small. */
        var representatives = [MazeCell: MazeCell]()
        for row in 0..<numRows {
            for col in 0..<numCols {
                let elem = maze[row][col];
                representatives[elem] = elem;
            }
        }

        /* Run a randomized Kruskal's algorithm to build the maze. */
        var edgesLeft = numRows * numCols - 1;
        for i in 0..<edges.count {
          if (edgesLeft > 0) {
            let edge = edges[i];

            /* See if they're linked already. */
            let rep1 = repFor(representatives, edge.from);
            let rep2 = repFor(representatives, edge.to);

            /* If not, link them. */
            if (rep1 != rep2) {
                representatives[rep1] = rep2;
                
                link(edge.from, edge.to, edge.fromPort);
                link(edge.to, edge.from, edge.toPort);

                edgesLeft -= 1;
            }
          }
        }
        if edgesLeft != 0 { print("Edges remain?") } // Internal error!

        return maze;
    }





}

