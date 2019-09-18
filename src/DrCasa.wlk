class Enfermedad { //Clase abstracta
	var property cantidadCelulasAmenazadas = 0
	
	method atenuarEn(cantidadCelulas) {
		cantidadCelulasAmenazadas -= cantidadCelulas
		}
		
	method recibirDosis (cantidadCelulas, unaPersona) {
		self.atenuarEn(cantidadCelulas)
		if(cantidadCelulasAmenazadas <= 0){
			unaPersona.curarse(self)
		}
	}
	method aplicarEfecto(unaPersona)
	method esAgresiva(cantidadCelulasPersona)
}

class EnfermedadInfecciosa inherits Enfermedad {

	method reproducirse() {
		cantidadCelulasAmenazadas *= 2
	}
	override method aplicarEfecto(unaPersona) {
		unaPersona.aumentarTemperatura(cantidadCelulasAmenazadas/1000)
	}
	override method esAgresiva(cantidadCelulasPersona) {
		return cantidadCelulasAmenazadas > cantidadCelulasPersona * 0.1
	}
}

class EnfermedadAutoinmune inherits Enfermedad {
	var diasQueAfectaste = 0
	
	override method aplicarEfecto(unaPersona) {
		unaPersona.destruirCelulas(cantidadCelulasAmenazadas)
		diasQueAfectaste ++
	}
	override method esAgresiva(cantidadCelulas) {
		return diasQueAfectaste > 30
	}

}

class Persona {
	const property enfermedades = #{} // Es const porque nunca cambia que sea un set
	var property temperatura
	var property cantidadCelulas
	var property factorSanguineo
	
	constructor(_temperatura,_cantidadCelulas,_enfermedades) {
		temperatura = _temperatura
		cantidadCelulas = _cantidadCelulas
		enfermedades = _enfermedades
	}
	
	method contraerEnfermedad(unaEnfermedad) {
		enfermedades.add(unaEnfermedad)
	}
	method tiene(unaEnfermedad) {
		return enfermedades.contains(unaEnfermedad)
	}
	method vivirUnDia() {
		enfermedades.forEach({enfermedad => enfermedad.aplicarEfecto(self)})
	}
	method aumentarTemperatura(unosGrados) {
		temperatura = 45.min(temperatura + unosGrados)
	}
	method destruirCelulas(unasCelulas) {
		cantidadCelulas -= unasCelulas
	}
	method cantidadCelulasAmenazadasPorEnfermedadesAgresivas() {
		return self.enfermedadesAgresivas().sum({enfermedad => enfermedad.cantidadCelulasAmenazadas()})
	}
	method enfermedadesAgresivas() {
		return enfermedades.filter({enfermedad => enfermedad.esAgresiva(cantidadCelulas)})
	}
	method aplicarDosis(unaDosis) {
		enfermedades.forEach({enfermedad => enfermedad.recibirDosis(unaDosis*15,self)})
	}
	method curarse(unaEnfermedad) {
		enfermedades.remove(unaEnfermedad)
	}
	method puedeDonar(unasCelulas){
		return unasCelulas > 500 && unasCelulas <= cantidadCelulas/4
	}
	method esCompatibleCon(otraPersona){
		return factorSanguineo == otraPersona.factorSanguineo()
	}
	method donar(unasCelulas) {
		self.destruirCelulas(unasCelulas)
	}
	method recibir(unasCelulas) {
		cantidadCelulas += unasCelulas
	}
}

class Medico inherits Persona {
	var property dosis
	
	method atenderA(unaPersona) {
		unaPersona.aplicarDosis(dosis)
	}
	
	override method contraerEnfermedad(unaEnfermedad) {
		super(unaEnfermedad) // Busca el mismo metodo en la clase de arriba
		self.atenderA(self)
	}	
}

class JefeDeDepartamento inherits Medico {
	var property subordinados = #{}
	override method atenderA(unaPersona) {
		subordinados.anyOne().atenderA(unaPersona)
	}
}

class Transfusion {
	var donante
	var receptor
	var cantidadDeCelulas
	
	method realizar() {
		self.validarDonante()
		self.validarCompatibilidad()
		donante.donar(cantidadDeCelulas)
		receptor.recibir(cantidadDeCelulas)
	}
	
	method validarCompatibilidad() {
		if(donante.esCompatibleCon(receptor).negate()) {
			throw new TransfusionException(message= "NO SE PUEDE DONAR")
		}
	}
	
	method validarDonante() {
		if (donante.puedeDonar(cantidadDeCelulas).negate()) {
			throw new TransfusionException(message= "NO SON COMPATIBLES")
		}
	}
}

class TransfusionException inherits Exception {}