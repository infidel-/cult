// save game object

import Cult;
import Static;

typedef _SaveGame = {
  var version: String;
  var mode: String;
  var date: String;
  var currentPlayerID: Int;
  var turns: Int;
  var difficulty: DifficultyInfo; // will work for single, custom and multi
  var artifacts: _SaveArtifacts;
  var flags: Flags;
  var lastNodeIndex: Int;
  var nodes: Array<_SaveNode>;
  var cults: Array<_SaveCult>;
  var lines: Array<_SaveLine>;
}

typedef _SaveNode = {
  var id: Int;
  var type: String;
  var name: String;
  var nation: Int;
  var job: String;
  var gender: Bool;
  var jobID: Int;
  var imageID: Int;
  var power: Array<Int>;
  @:optional var powerGenerated: Array<Int>;
  var x: Int;
  var y: Int;
  var centerX: Int;
  var centerY: Int;
  var vis: Array<Bool>;
  var isKnown: Array<Bool>;
  var isTempGenerator: Bool; // temporary generator?
  var isProtected: Bool; // node protected by neighbours?
  var level: Int;
  var owner: Int;
  var artifact: Int;
}

typedef _SaveLine = {
  var start: Int;
  var end: Int;
  var owner: Int;
  var vis: Array<Bool>;
}

typedef _SaveCult = {
  var id: Int;
  var infoID: Int;
  var difficulty: Int;
  var isInfoKnown: Array<Bool>;
  var isDiscovered: Array<Bool>;
  var isAI: Bool;
  var isDead: Bool;
  var isParalyzed: Bool;
  var paralyzedTurns: Int;
  @:optional var ritual: String;
  var ritualPoints: Int;
  var awarenessMod: Int;
  var awarenessBase: Int;
  var power: Array<Int>;
  var wars: Array<Bool>;
  var origin: Int;
  var adeptsUsed: Int;
  var sects: Array<_SaveSect>;
  var investigatorTimeout: Int;
  @:optional var investigator: _SaveInvestigator;
  var logMessages: String;
  var logMessagesTurn: String;
  //var logPanelMessages: Array<_SaveMessage>;
  var logPanelMessages: Array<LogPanelMessage>;
  var artifacts: _SaveCultArtifacts;
  var fluffShown: Array<String>;
}

typedef _SaveSect = {
  var id: Int;
  var name: String;
  var leader: Int;
  var cult: Int;
  var size: Int;
  var level: Int;
  var isAdvisor: Bool;
  var isDevoted: Bool;
  var task: String;
  var taskPoints: Int;
  var taskTarget: Int;
  var taskImportant: Bool;
  var powerID: Int;
  var powerStorage: Int;
}

typedef _SaveInvestigator = {
  var name: String;
  var will: Int;
  var level: Int;
  var isHidden: Bool;
}

typedef _SaveCultArtifacts = {
  var storage: Array<_SaveCultArtifact>;
}

typedef _SaveCultArtifact = {
  var name: String;
  var id: String;
  var level: Int;
  var isUnique: Bool;
  var node: Int;
}

typedef _SaveArtifacts = {
  var deleted: Array<String>;
}

typedef _SaveArtifactNode = {
  > _SaveNode,
  var turns: Int;
  var artifactType: String;
  var artifactTypeID: Int;
  var isUnique: Bool;
  var artifactID: String;
}
