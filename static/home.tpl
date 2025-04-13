<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Daily Todo List</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">

  <!-- FontAwesome -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Vue.js -->
  <script src="https://unpkg.com/vue@2.6.14/dist/vue.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/vue-resource@1.5.1"></script>

  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Poppins', sans-serif;
      background: linear-gradient(135deg, #667eea, #764ba2);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }
    .container {
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(15px);
      padding: 30px;
      border-radius: 20px;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
      width: 400px;
      max-width: 90%;
      animation: fadeIn 1s ease;
      position: relative;
    }
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .todo-title {
      text-align: center;
      color: #fff;
      font-size: 28px;
      font-weight: 700;
      margin-bottom: 20px;
      text-shadow: 0 2px 4px rgba(0,0,0,0.4);
    }
    .input-group {
      display: flex;
      margin-bottom: 20px;
    }
    input[type="text"] {
      flex: 1;
      padding: 12px 15px;
      background: rgba(55, 47, 47, 0.2);
      border: none;
      border-radius: 12px 0 0 12px;
      color: white;
      font-size: 16px;
    }
    input::placeholder {
      color: #ddd;
    }
    input:focus {
      outline: none;
      background: rgba(40, 31, 31, 0.3);
    }
    .add-btn {
      padding: 0 20px;
      background: linear-gradient(to right, #5E35B1, #512DA8);
      border: none;
      border-radius: 0 12px 12px 0;
      color: white;
      font-size: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: 0.3s;
    }
    .add-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
    }
    ul { list-style: none; }
    li {
      background: rgba(255, 255, 255, 0.15);
      margin-bottom: 10px;
      padding: 10px 15px;
      border-radius: 12px;
      color: white;
      font-weight: 600;
      display: flex;
      align-items: center;
      justify-content: space-between;
      transition: 0.3s ease;
      animation: fadeIn 0.5s ease;
    }
    li:hover {
      background: rgba(49, 47, 47, 0.25);
    }
    .todo-text {
      display: flex;
      align-items: center;
      gap: 10px;
      cursor: pointer;
    }
    .todo-text span {
      font-size: 16px;
    }
    .todo-text.completed span {
      text-decoration: line-through;
      color: #593e9a;
    }
    .actions {
      display: flex;
      gap: 10px;
    }
    .actions button {
      background: transparent;
      border: none;
      color: white;
      font-size: 18px;
      cursor: pointer;
      transition: 0.3s;
    }
    .actions button:hover {
      color: #ffd700;
      transform: scale(1.1);
    }

    /* Modal Styles */
    .modal-overlay {
      position: fixed;
      top: 0; left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.6);
      display: flex;
      justify-content: center;
      align-items: center;
      z-index: 1000;
    }
    .modal-box {
      background: white;
      color: #333;
      padding: 30px;
      border-radius: 12px;
      width: 300px;
      text-align: center;
      animation: fadeIn 0.3s ease;
    }
    .modal-actions {
      margin-top: 20px;
      display: flex;
      justify-content: space-around;
    }
    .btn-delete {
      background: #e74c3c;
      border: none;
      padding: 10px 20px;
      color: white;
      border-radius: 8px;
      cursor: pointer;
    }
    .btn-cancel {
      background: #3498db;
      border: none;
      padding: 10px 20px;
      color: white;
      border-radius: 8px;
      cursor: pointer;
    }
    .btn-delete:hover, .btn-cancel:hover {
      opacity: 0.8;
    }
  </style>
</head>

<body>
<div id="root" class="container">
  <h1 class="todo-title">Daily Todo Lists</h1>

  <form v-on:submit.prevent class="input-group">
    <input type="text" v-model="todo.title" placeholder="Add your todo" @keyup.enter="addTodo">
    <button type="button" class="add-btn" @click="addTodo">
      <i :class="enableEdit ? 'fa fa-edit' : 'fa fa-plus'"></i>
    </button>
  </form>

  <ul>
    <li v-for="(todo, index) in todos" :key="todo.id">
      <div class="todo-text" :class="{ 'completed': todo.completed }" @click="toggleTodo(todo, index)">
        <i :class="todo.completed ? 'fas fa-check-circle text-success' : 'fas fa-circle'"></i>
        <span>@{ todo.title }</span>
      </div>
      <div class="actions">
        <button @click.prevent.stop="editTodo(todo)">
          <i class="fas fa-edit"></i>
        </button>
        <button @click.prevent.stop="startDelete(todo, index)">
          <i class="fas fa-trash"></i>
        </button>
      </div>
    </li>
  </ul>

  <!-- Delete Modal -->
  <div v-if="showDeleteModal" class="modal-overlay">
    <div class="modal-box">
      <h2>Confirm Deletion</h2>
      <p>Are you sure you want to delete this todo?</p>
      <div class="modal-actions">
        <button @click="confirmDelete" class="btn-delete">Delete</button>
        <button @click="cancelDelete" class="btn-cancel">Cancel</button>
      </div>
    </div>
  </div>
</div>

<script>
  var Vue = new Vue({
    el: '#root',
    delimiters: ['@{', '}'],
    data: {
      showError: false,
      enableEdit: false,
      todo: { id: '', title: '', completed: false },
      todos: [],
      showDeleteModal: false,
      deleteTodoId: null,
      deleteTodoIndex: null
    },
    mounted () {
      this.fetchTodos();
    },
    methods: {
      fetchTodos() {
        this.$http.get('todo').then(response => {
          this.todos = response.body.data;
        });
      },
      addTodo() {
        if (this.todo.title.trim() === '') {
          this.showError = true;
        } else {
          this.showError = false;
          if (this.enableEdit) {
            this.$http.put('todo/' + this.todo.id, { 
              title: this.todo.title, 
              completed: this.todo.completed 
            }).then(response => {
              if (response.status == 200) {
                const index = this.todos.findIndex(t => t.id === this.todo.id);
                if (index !== -1) {
                  this.todos[index].title = this.todo.title;
                }
                this.todo = { id: '', title: '', completed: false };
                this.enableEdit = false;
              }
            });
          } else {
            this.$http.post('todo', { title: this.todo.title }).then(response => {
              if (response.status == 201) {
                this.todos.push({ id: response.body.todo_id, title: this.todo.title, completed: false });
                this.todo = { id: '', title: '', completed: false };
              }
            });
          }
        }
      },
      toggleTodo(todo, index) {
        let newStatus = !todo.completed;
        this.$http.put('todo/' + todo.id, { title: todo.title, completed: newStatus }).then(response => {
          if (response.status == 200) {
            this.todos[index].completed = newStatus;
          }
        });
      },
      editTodo(todo) {
        this.enableEdit = true;
        this.todo = { id: todo.id, title: todo.title, completed: todo.completed };
      },
      startDelete(todo, index) {
        this.showDeleteModal = true;
        this.deleteTodoId = todo.id;
        this.deleteTodoIndex = index;
      },
      confirmDelete() {
        this.$http.delete('todo/' + this.deleteTodoId).then(response => {
          if (response.status == 200) {
            this.todos.splice(this.deleteTodoIndex, 1);
          }
          this.resetDeleteModal();
        });
      },
      cancelDelete() {
        this.resetDeleteModal();
      },
      resetDeleteModal() {
        this.showDeleteModal = false;
        this.deleteTodoId = null;
        this.deleteTodoIndex = null;
      }
    }
  });
</script>

</body>
</html>
