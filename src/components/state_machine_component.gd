extends Node
class_name StateMachineComponent

# Array berisi macam-macam state
var states: Array = []

# State yang sedang aktif/di seleksi
var current_state: State = null

func _ready() -> void:
	initializeState()

func _process(delta: float) -> void:
	pass
	#if current_state != null:
	#	current_state.onStateProcess.emit()
		
func _physics_process(delta: float) -> void:
	pass
	#if current_state != null:
	#	current_state.onStatePhysicsProcess.emit()

func initializeState():
	# Sets current state to the first state
	# Inisialisasi state
	if states.is_empty():
		printerr("No states exist")
	else:
		current_state = getStateByName("Idle")
		current_state.onStateEnter.emit()
		print("Initialized state with " + current_state.state_name)

# Tambah state ke array state
func addState(state: State):
	states.push_back(state)
	print("Adding state " + state.state_name, " to state list.")

# Hapus state dari array state
func removeState(state: State):
	if not states.is_empty():
		if states.has(state):
			states.remove_at(states.find(state))

# Ubah state ke state yang baru
func changeState(new_state: State):
	if current_state == new_state:
		return
	
	var previous_state = current_state
	current_state.onStateExit.emit()
	current_state = new_state
	current_state.onStateEnter.emit()
	#print("Changed state from " + previous_state.state_name, " to " + new_state.state_name, ".")

# Ambil state dari nama state
func getStateByName(state_name: String):
	for state in states:
		if state is State:
			if state.state_name == state_name:
				print("Got state " + state.state_name, " from state list.")
				return state
			else:
				printerr("Didn't find state.")
