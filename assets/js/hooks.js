const DRAG_ATTRIBUTE_NAME = 'phx-drop-target';
const DROP_TARGET_BG = 'bg-slate-50';
const EXEMPLAR_FILE_INPUT_ID = 'exemplar-file-input'

export const DragHook = {
	// handleDrop(event) {
	// 	const files = event.dataTransfer.files;
	// 	const fileInputDiv = document.getElementById(`${EXEMPLAR_FILE_INPUT_ID}`);
	// 	const fileInput = fileInputDiv.querySelector('input');
	// 	this.uploadTo(fileInput, "exemplar_file", files);
	// },

	isDropTarget(event) {
		const target = event.target;
		return target.getAttribute(DRAG_ATTRIBUTE_NAME) !== null;
	},

	mounted() {
		document.addEventListener('dragenter', event => {
			if (this.isDropTarget(event)) {
				event.target.classList.add(DROP_TARGET_BG);
			}
		});

		document.addEventListener('dragleave', event => {
			if (this.isDropTarget(event)) {
				event.target.classList.remove(DROP_TARGET_BG);
			}
		})
	}
};

export default {
	DragHook
};
